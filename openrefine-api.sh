#!/bin/bash
# List the HTTP API of an OpenRefine release as found in its source code:
# commands (with request parameters), operations (with JSON properties),
# importers and exporters (with options and default values).
#
# Usage:
#   ./openrefine-api.sh VERSION              print report for one release
#   ./openrefine-api.sh VERSION1 VERSION2    print diff between two releases
#
# VERSION is a git tag of https://github.com/OpenRefine/OpenRefine (e.g. 3.10.1)
# or the path to a local OpenRefine source checkout.
#
# Requires: bash, git, perl, diff
#
# The report is generated with regular expressions from the Java source, so it
# is a heuristic: it shows what the code reads, not what is documented. Use the
# diff between the release orcli currently supports and a new release to find
# changes that may require changes in orcli.
#
# Sources:
#   - commands, operations, importers, exporters: main/webapp/modules/core/MOD-INF/controller.js
#   - command parameters: request.getParameter("x"), getIntegerParameter(request, "x", default),
#     parameters.get("x"); "project", "engine" and "csrf_token" are implied by
#     getProject(), getEngineConfig() and hasValidCSRFToken[AsGET]()
#   - operation properties: @JsonProperty parameters of the @JsonCreator constructor
#   - importer options: "UI default" is what createParserUIInitializationData() sets
#     (used by OpenRefine's web interface and by create-project-from-upload without "options"),
#     "parse default" is the fallback in JSONUtilities.getXxx(options, "x", default)
#     (used when an option is missing in the "options" JSON, which is how orcli imports)
#   - exporter options: params.getProperty("x") (request parameters), JSONUtilities.getXxx(options, ...)
#     and @JsonProperty fields with initializers (keys of the "options" JSON)

set -euo pipefail

usage() {
  sed -n '2,/^$/s/^# \{0,1\}//p' "$0" >&2
  exit 1
}

if [[ $# -lt 1 || $# -gt 2 || $1 == -h || $1 == --help ]]; then
  usage
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# fetch source of an OpenRefine release (sparse, without history) and print its path
fetch() {
  local version="$1" dir
  if [[ -d "${version}" ]]; then
    echo "${version}"
    return
  fi
  dir="${tmpdir}/${version}"
  echo "fetching OpenRefine ${version} source code..." >&2
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch "${version}" \
    --filter=blob:none --sparse https://github.com/OpenRefine/OpenRefine.git "${dir}" >&2 ||
    { echo "OpenRefine version ${version} not found" >&2; exit 1; }
  git -C "${dir}" sparse-checkout set main/src modules main/webapp/modules/core/MOD-INF >&2 || exit 1
  echo "${dir}"
}

read -r -d '' PARSER <<'PERL' || true
use strict;
use warnings;
use File::Find;

my ($root, $label) = @ARGV;
my $controller = "$root/main/webapp/modules/core/MOD-INF/controller.js";
die "controller.js not found in $root\n" unless -f $controller;

# ---------------------------------------------------------------- helpers

sub slurp { my ($f) = @_; open(my $fh, '<', $f) or die "$f: $!"; local $/; my $t = <$fh>; close $fh; return $t; }

# remove comments, keep string and char literals
sub strip_comments {
  my ($t) = @_;
  $t =~ s{("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|//[^\n]*|/\*.*?\*/}{defined $1 ? $1 : ' '}gse;
  return $t;
}

# position of the bracket matching the one at $pos, skipping literals
sub match_bracket {
  my ($t, $pos) = @_;
  my $open = substr($t, $pos, 1);
  my $close = { '(' => ')', '{' => '}', '[' => ']' }->{$open};
  my $depth = 0;
  for (my $i = $pos; $i < length $t; $i++) {
    my $c = substr($t, $i, 1);
    if ($c eq '"' || $c eq "'") {
      for ($i++; $i < length $t; $i++) {
        my $d = substr($t, $i, 1);
        if ($d eq '\\') { $i++; next; }
        last if $d eq $c;
      }
      next;
    }
    $depth++ if $c eq $open;
    if ($c eq $close) { $depth--; return $i if $depth == 0; }
  }
  return length $t;
}

# split argument list at top-level commas
sub split_args {
  my ($s) = @_;
  my (@args, $cur, $depth);
  $cur = ''; $depth = 0;
  for (my $i = 0; $i < length $s; $i++) {
    my $c = substr($s, $i, 1);
    if ($c eq '"' || $c eq "'") {
      my $j = $i;
      for ($j++; $j < length $s; $j++) {
        my $d = substr($s, $j, 1);
        if ($d eq '\\') { $j++; next; }
        last if $d eq $c;
      }
      $cur .= substr($s, $i, $j - $i + 1); $i = $j; next;
    }
    $depth++ if $c =~ /[(\[{<]/;
    $depth-- if $c =~ /[)\]}>]/;
    if ($c eq ',' && $depth == 0) { push @args, $cur; $cur = ''; next; }
    $cur .= $c;
  }
  push @args, $cur if $cur =~ /\S/;
  return map { my $a = $_; $a =~ s/\s+/ /g; $a =~ s/^ | $//g; $a } @args;
}

# all calls matching regex $callee: list of [position, args...]
sub find_calls {
  my ($t, $callee) = @_;
  my @calls;
  while ($t =~ /$callee\s*\(/g) {
    my $open = pos($t) - 1;
    my $close = match_bracket($t, $open);
    push @calls, [$-[0], split_args(substr($t, $open + 1, $close - $open - 1))];
    pos($t) = $open + 1;
  }
  return @calls;
}

# bodies of methods/constructors named $name
sub method_bodies {
  my ($t, $name) = @_;
  my @bodies;
  while ($t =~ /\b\Q$name\E\s*\(/g) {
    my $close = match_bracket($t, pos($t) - 1);
    my $rest = substr($t, $close + 1, 300);
    if ($rest =~ /^\s*(?:throws\s+[\w.,\s]+)?\{/) {
      my $open = $close + 1 + $+[0] - 1;
      push @bodies, substr($t, $open, match_bracket($t, $open) - $open + 1);
    }
  }
  return @bodies;
}

sub norm { my ($s) = @_; $s =~ s/\s+/ /g; $s =~ s/^ | $//g; return $s; }

# ---------------------------------------------------------------- class index

my (%file_of, %by_simple, %src, %consts);
find({ no_chdir => 1, wanted => sub {
  return unless /\.java$/ && m{/src/(?:main/java/)?(?:com|org)/};
  return if m{/tests?/};
  my $f = $_;
  my $t = strip_comments(slurp($f));
  my ($pkg) = $t =~ /^\s*package\s+([\w.]+)\s*;/m;
  return unless $pkg;
  (my $simple = $f) =~ s{.*/|\.java$}{}g;
  my $fqcn = "$pkg.$simple";
  $file_of{$fqcn} = $f;
  push @{$by_simple{$simple}}, $fqcn;
  $src{$fqcn} = $t;
  while ($t =~ /\bstatic\s+final\s+String\s+(\w+)\s*=\s*("(?:\\.|[^"\\])*")\s*;/g) {
    $consts{$fqcn}{$1} = $2;
  }
}}, grep { -d } "$root/main/src", glob("$root/modules/*/src/main/java"));

# resolve a simple class name used in class $ctx
sub resolve {
  my ($ctx, $name) = @_;
  $name =~ s/<.*//s;
  return $name if exists $src{$name};
  my $t = $src{$ctx} // '';
  return $1 if $t =~ /^\s*import\s+([\w.]+\.\Q$name\E)\s*;/m && exists $src{$1};
  (my $pkg = $ctx) =~ s/\.\w+$//;
  return "$pkg.$name" if exists $src{"$pkg.$name"};
  my $c = $by_simple{$name} // [];
  return $c->[0] if @$c == 1;
  return undef;
}

# class and its superclasses (as long as their source is available)
sub chain {
  my ($fqcn) = @_;
  my @chain;
  while (defined $fqcn && exists $src{$fqcn} && !grep { $_ eq $fqcn } @chain) {
    push @chain, $fqcn;
    (my $simple = $fqcn) =~ s/.*\.//;
    my ($parent) = $src{$fqcn} =~ /\bclass\s+\Q$simple\E\b(?:\s*<[^{]*?>)?\s+extends\s+([\w.]+)/;
    $fqcn = defined $parent ? resolve($fqcn, $parent) : undef;
  }
  return @chain;
}

# option key from a string literal or a String constant
sub key_of {
  my ($ctx, $arg) = @_;
  return undef unless defined $arg;
  return $1 if $arg =~ /^"((?:\\.|[^"\\])*)"$/;
  if ($arg =~ /^(?:([\w.]+)\.)?(\w+)$/) {
    my ($cls, $name) = ($1, $2);
    my $c = defined $cls ? resolve($ctx, $cls) : $ctx;
    for my $k (grep { defined } $c, $ctx) {
      return substr($consts{$k}{$name}, 1, -1) if exists $consts{$k}{$name};
    }
    for my $k (sort keys %consts) {
      return substr($consts{$k}{$name}, 1, -1) if exists $consts{$k}{$name};
    }
  }
  return "<$arg>";
}

sub short { my ($fqcn) = @_; $fqcn =~ s/.*\.//; return $fqcn; }

# name of the (inner) class enclosing position $pos
sub enclosing_class {
  my ($t, $pos) = @_;
  my $best;
  while ($t =~ /\b(?:class|enum)\s+(\w+)[^{;]*\{/g) {
    my $open = $+[0] - 1;
    last if $open > $pos;
    $best = $1 if match_bracket($t, $open) > $pos;
  }
  return $best;
}

# ---------------------------------------------------------------- extractors

# options read with JSONUtilities.getXxx(obj, "key", default) from objects named *option*
sub json_reads {
  my ($fqcn, $t, $objre) = @_;
  my @r;
  for my $c (find_calls($t, qr/\bJSONUtilities\s*\.\s*get(\w+)/)) {
    my ($pos, $obj, $key, $def) = @$c;
    next unless defined $obj && $obj =~ $objre;
    my ($type) = substr($t, $pos) =~ /^JSONUtilities\s*\.\s*get(\w+)/;
    push @r, { key => key_of($fqcn, $key), type => $type, default => $def, pos => $pos };
  }
  return @r;
}

# fields annotated with @JsonProperty("key") and their initializers
sub json_fields {
  my ($t) = @_;
  my @r;
  my $type = qr/[\w.]+(?:<[^;(){}]*?>)?(?:\[\])*/;
  while ($t =~ /\@JsonProperty\(\s*(?:value\s*=\s*)?"([^"]+)"[^)]*\)\s*((?:(?:public|protected|private|final|static|transient)\s+)*)($type)\s+(\w+)\s*(?:=\s*([^;]+?))?\s*;/g) {
    next if $2 =~ /static/;
    push @r, { key => $1, type => $3, default => defined $5 ? norm($5) : undef, pos => $-[0] };
  }
  return @r;
}

# ---------------------------------------------------------------- controller.js

my $js = strip_comments(slurp($controller));
$js =~ s/\s+/ /g;

my (@commands, @operations, @formats, @exporters);
push @commands, [$1, $2] while $js =~ /registerCommand\(\s*module\s*,\s*"([^"]+)"\s*,\s*(?:new\s+)?Packages\.([\w.]+)\s*\(/g;
push @operations, [$1, $2] while $js =~ /registerOperation\(\s*module\s*,\s*"([^"]+)"\s*,\s*Packages\.([\w.]+)/g;
while ($js =~ /registerFormat\(\s*"([^"]+)"\s*,\s*"([^"]+)"([^;]*?)\)\s*;/g) {
  my ($name, $label, $rest) = ($1, $2, $3);
  my ($cls, $args) = $rest =~ /new\s+Packages\.([\w.]+)\s*\(([^)]*)\)/;
  push @formats, [$name, $cls, $args];
}
# exporters are registered in ExporterRegistry (until 3.8) or in controller.js (since 3.9)
for my $reg (grep { /\.exporters\.ExporterRegistry$/ } keys %src) {
  my $t = $src{$reg};
  $t =~ s/\s+/ /g;
  while ($t =~ /\.put\(\s*"([^"]+)"\s*,\s*new\s+([\w.]+)\s*\(\s*(.*?)\s*\)\s*\)\s*;/g) {
    push @exporters, [$1, resolve($reg, $2) // $2, $3];
  }
}
while ($js =~ /registerExporter\(\s*"([^"]+)"\s*,\s*new\s+Packages\.([\w.]+)\s*\(\s*(.*?)\s*\)\s*\)\s*;/g) {
  my $e = [$1, $2, $3];
  my ($i) = grep { $exporters[$_][0] eq $e->[0] } 0 .. $#exporters;
  if (defined $i) { $exporters[$i] = $e } else { push @exporters, $e }
}

my ($version) = $label;
print "# OpenRefine $version: HTTP API\n\n";
print "Generated by openrefine-api.sh from the OpenRefine source code.\n";

# ---------------------------------------------------------------- commands

print "\n## Commands\n\n";
print "POST/GET: methods implemented by the command class. Parameters are request parameters (query string or form data).\n";
for my $cmd (@commands) {
  my ($name, $fqcn) = @$cmd;
  my @chain = grep { short($_) ne 'Command' } chain($fqcn);
  my (%methods, @params, %seen);
  my $add = sub { my ($p) = @_; push @params, $p unless $seen{$p->[0]}++; };
  for my $c (@chain) {
    my $t = $src{$c};
    $methods{POST} = 1 if $t =~ /\bvoid\s+doPost\s*\(/;
    $methods{GET} = 1 if $t =~ /\bvoid\s+doGet\s*\(/;
    $add->(['csrf_token']) if $t =~ /\bhasValidCSRFToken\s*\(/;
    $add->(['csrf_token (in query string)']) if $t =~ /\bhasValidCSRFTokenAsGET\s*\(/;
    $add->(['project']) if $t =~ /\bgetProject(?:Metadata)?\s*\(\s*request\s*\)/;
    $add->(['engine']) if $t =~ /\bget(?:Engine|EngineConfig)\s*\(\s*request\b/;
    for my $call (find_calls($t, qr/\brequest\s*\.\s*getParameter/)) {
      my $k = key_of($c, $call->[1]); $add->([$k]) if defined $k && $k !~ /^</;
    }
    for my $call (find_calls($t, qr/\bgetIntegerParameter/)) {
      my $k = key_of($c, $call->[2]); $add->([$k, $call->[3]]) if defined $k && $k !~ /^</;
    }
    for my $call (find_calls($t, qr/\b(?:parameters|params|options)\s*\.\s*get(?:Property)?/)) {
      my $k = key_of($c, $call->[1]); $add->([$k]) if defined $k && $k !~ /^</;
    }
    # CreateProjectCommand: legacy parameters mapped to importer options
    for my $call (find_calls($t, qr/\badjustLegacy\w*Option/)) {
      my ($k, $o) = (key_of($c, $call->[4]), key_of($c, $call->[5]));
      $add->(["$k (legacy, sets option $o)"]) if defined $k && $k !~ /^</ && defined $o && $o !~ /^</;
    }
  }
  my $methods = join('/', grep { $methods{$_} } qw(POST GET)) || '?';
  my $cls = exists $src{$fqcn} ? short($fqcn) : "$fqcn (source not found)";
  print "\n### $name\n\n";
  print "$methods $cls\n\n";
  print map { defined $_->[1] ? "- $_->[0] (default: $_->[1])\n" : "- $_->[0]\n" } @params;
  print "- (no parameters found)\n" unless @params;
}

# ---------------------------------------------------------------- operations

print "\n## Operations\n\n";
print "Properties of the operation JSON (as in apply-operations and the undo/redo history), from the \@JsonCreator constructor.\n";
for my $op (@operations) {
  my ($name, $fqcn) = @$op;
  my @props;
  my %seen;
  for my $c (chain($fqcn)) {
    my $t = $src{$c};
    my $found = 0;
    while ($t =~ /\@JsonCreator\b/g) {
      my $inner = enclosing_class($t, $-[0]) // short($c);
      my $prefix = $inner eq short($c) ? '' : "$inner.";
      next unless $t =~ /\G[^;{]*?\(/g;
      my $open = pos($t) - 1;
      my $close = match_bracket($t, $open);
      for my $arg (split_args(substr($t, $open + 1, $close - $open - 1))) {
        next unless $arg =~ /\@JsonProperty\(\s*(?:value\s*=\s*)?"([^"]+)"([^)]*)\)\s*(?:final\s+)?(.+?)\s+\w+$/;
        my ($k, $extra, $type) = ($1, $2, $3);
        $type =~ s/\@\w+(?:\([^)]*\))?\s*//g;
        push @props, ["$prefix$k", $type, $extra =~ /required\s*=\s*true/ ? ' (required)' : ''] unless $seen{"$prefix$k"}++;
        $found = 1;
      }
      pos($t) = $close;
    }
    last if $found;
  }
  print "\n### $name\n\n";
  print short($fqcn), "\n\n";
  print map { "- $_->[0]: $_->[1]$_->[2]\n" } @props;
  print "- (no \@JsonCreator properties found)\n" unless @props;
}

# ---------------------------------------------------------------- importers

sub print_table {
  my ($head, @rows) = @_;
  print "| ", join(" | ", @$head), " |\n";
  print "|", join("|", map { "---" } @$head), "|\n";
  for my $r (@rows) {
    print "| ", join(" | ", map { my $v = $_ // ''; $v =~ s/\|/\\|/g; $v eq '' ? ' ' : "`$v`" } @$r), " |\n";
  }
}

print "\n## Importers\n\n";
print "Options of the \"options\" JSON of create-project-from-upload (and importing-controller).\n";
print "UI default: set by createParserUIInitializationData() (OpenRefine web interface; create-project-from-upload without \"options\").\n";
print "Parse default: fallback if the option is missing in the \"options\" JSON (orcli always sends \"options\").\n";

my @common;
for my $c (grep { /\.ImportingUtilities$/ } keys %src) {
  push @common, map { [$_->{key}, $_->{type}, '', $_->{default}, short($c)] }
    json_reads($c, $src{$c}, qr/^optionObj$/);
}
if (@common) {
  print "\n### (all formats)\n\n";
  my %seen;
  print_table([qw(option type), 'UI default', 'parse default', 'source'], grep { !$seen{$_->[0]}++ } @common);
}

for my $f (@formats) {
  my ($name, $fqcn, $args) = @$f;
  next unless defined $fqcn;
  my (%rows, @order);
  for my $c (reverse chain($fqcn)) {
    my $t = $src{$c};
    for my $body (method_bodies($t, 'createParserUIInitializationData')) {
      for my $call (find_calls($body, qr/\bJSONUtilities\s*\.\s*safePut/)) {
        my (undef, $obj, $key, $val) = @$call;
        next unless $obj eq 'options';
        my $k = key_of($c, $key);
        push @order, $k unless $rows{$k};
        $rows{$k}{ui} = $val;
        $rows{$k}{src}{short($c)} = 1;
      }
    }
    for my $r (json_reads($c, $t, qr/^options$/)) {
      my $k = $r->{key};
      push @order, $k unless $rows{$k};
      $rows{$k}{type} //= $r->{type};
      my $d = $r->{default} // '';
      push @{$rows{$k}{parse}}, $d unless grep { $_ eq $d } @{$rows{$k}{parse} // []};
      $rows{$k}{src}{short($c)} = 1;
    }
  }
  print "\n### $name\n\n";
  print short($fqcn), ($args =~ /\S/ ? "($args)" : ''), (map { " < " . short($_) } (chain($fqcn))[1 .. scalar(chain($fqcn)) - 1]), "\n\n";
  print_table([qw(option type), 'UI default', 'parse default', 'source'],
    map { [$_, $rows{$_}{type}, $rows{$_}{ui}, join(' / ', @{$rows{$_}{parse} // []}), join(', ', sort keys %{$rows{$_}{src}})] } @order);
}

# ---------------------------------------------------------------- exporters

print "\n## Exporters\n\n";
print "Options for export-rows (format=<name>, see command export-rows for its other parameters).\n";
print "\"param\" options are request parameters, \"options\" options are keys of the \"options\" JSON parameter.\n";

sub exporter_rows {
  my ($c) = @_;
  my $t = $src{$c};
  my (@rows, %seen);
  for my $call (find_calls($t, qr/\b(?:params|options|parameters)\s*\.\s*getProperty/)) {
    my $k = key_of($c, $call->[1]);
    push @rows, ['param', $k, 'String', '', short($c)] unless $seen{"param $k"}++;
  }
  for my $r (json_reads($c, $t, qr/option|settings/i), json_fields($t)) {
    my $inner = enclosing_class($t, $r->{pos}) // short($c);
    my $where = $inner eq short($c) ? $inner : short($c) . ".$inner";
    push @rows, ['options', $r->{key}, $r->{type}, $r->{default}, $where] unless $seen{"options $r->{key} $where"}++;
  }
  return @rows;
}

my (@helpers, %helper_seen);
for my $e (@exporters) {
  my ($name, $fqcn, $args) = @$e;
  my @classes = chain($fqcn);
  # helper classes of the exporters packages used by the exporter (e.g. CustomizableTabularExporterUtilities)
  my @uses;
  my @todo = @classes;
  while (my $c = shift @todo) {
    for my $other (sort grep { /\.exporters\.(?:\w+\.)?\w+$/ } keys %src) {
      next if grep { $_ eq $other } @classes, @uses;
      my $s = short($other);
      next unless $src{$c} =~ /\b\Q$s\E\s*\./ && exporter_rows($other);
      push @uses, $other; push @todo, $other;
      push @helpers, $other unless $helper_seen{$other}++;
    }
  }
  print "\n### $name\n\n";
  print short($fqcn), "($args)", (map { " < " . short($_) } (chain($fqcn))[1 .. scalar(chain($fqcn)) - 1]), "\n";
  print "\nalso uses options of: ", join(', ', map { short($_) } @uses), "\n" if @uses;
  my @rows = map { exporter_rows($_) } chain($fqcn);
  if (@rows) { print "\n"; print_table([qw(kind option type default source)], @rows); }
}

for my $c (@helpers) {
  print "\n### ", short($c), "\n\n";
  print_table([qw(kind option type default source)], exporter_rows($c));
}
PERL

report() {
  local dir
  dir="$(fetch "$1")"
  perl -e "${PARSER}" -- "${dir}" "$(basename "$1")"
}

if [[ $# -eq 1 ]]; then
  report "$1"
else
  report "$1" > "${tmpdir}/a.md"
  report "$2" > "${tmpdir}/b.md"
  diff -u --label "$1" --label "$2" "${tmpdir}/a.md" "${tmpdir}/b.md" || true
fi
