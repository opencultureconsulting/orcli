document.addEventListener('DOMContentLoaded', function () {
  // Global preview box
  const globalPreview = document.getElementById('global-cli-preview');
  const previewText = document.getElementById('cli-preview-text');

  // Get environment variables from sidebar
  function getGlobalEnvVars() {
    const envForm = document.querySelector('#sidebar form');
    if (!envForm) return [];
    const envVars = [];
    Array.from(envForm.elements).forEach(el => {
      if (el.name && el.value) {
        envVars.push(`${el.name}=${el.value}`);
      }
    });
    return envVars;
  }

  // Build CLI preview for a form
  function buildPreview(form) {
    const command = form.dataset.command;
    let cli = ['orcli', ...command.split(' ')];
    Array.from(form.elements).forEach(el => {
      if (!el.name || el.type === 'fieldset' || el.type === 'legend') return;
      if (el.tagName === 'SELECT' && el.multiple) {
        Array.from(el.selectedOptions).forEach(opt => {
          if (opt.value) cli.push(opt.value);
        });
      } else if (el.value) {
        if (el.name.startsWith('--')) {
          cli.push(el.name);
          if (el.value) cli.push(el.value);
        } else {
          cli.push(el.value);
        }
      }
    });
    const envVars = getGlobalEnvVars();
    return (envVars.length ? envVars.join(' ') + ' ' : '') + cli.join(' ');
  }

  // Update preview for current command
  function updateGlobalPreview() {
    // Find visible command section
    const visibleSection = Array.from(document.querySelectorAll('.command-section')).find(sec => sec.style.display === 'block');
    if (visibleSection) {
      const form = visibleSection.querySelector('.command-form');
      if (form) {
        previewText.textContent = buildPreview(form);
        return;
      }
    }
  }

  // Show only selected command section
  function showSection(id) {
    document.querySelectorAll('.command-section').forEach(sec => {
      sec.style.display = 'none';
    });
    const el = document.getElementById(id);
    if (el) el.style.display = 'block';
    // Hide examples
    const examples = document.getElementById('examples-section');
    if (examples) examples.style.display = 'none';
    updateGlobalPreview();
  }

  // Convert command name to section id
  function toSectionId(name) {
    return 'section-' + name.replace(/ /g, '-');
  }

  // Command navigation click
  document.querySelectorAll('.command-link').forEach(link => {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      showSection(toSectionId(this.dataset.command));
    });
  });

  // Initial: show only examples
  document.querySelectorAll('.command-section').forEach(sec => {
    sec.style.display = 'none';
  });
  const examples = document.getElementById('examples-section');
  if (examples) examples.style.display = 'block';
  updateGlobalPreview();

  // Update preview on form change
  document.querySelectorAll('.command-form').forEach(form => {
    form.addEventListener('input', updateGlobalPreview);
    form.addEventListener('change', updateGlobalPreview);
  });

  // Update preview on environment change
  const envForm = document.querySelector('#sidebar form');
  if (envForm) {
    envForm.addEventListener('input', updateGlobalPreview);
    envForm.addEventListener('change', updateGlobalPreview);
  }

  // Copy button logic
  const copyBtn = document.getElementById('copy-cli-preview');
  if (copyBtn && previewText) {
    copyBtn.addEventListener('click', () => {
      const text = previewText.textContent;
      navigator.clipboard.writeText(text).then(() => {
        copyBtn.textContent = '✔️ Copied!';
        copyBtn.style.color = '#2ecc40';
        copyBtn.style.minWidth = copyBtn.offsetWidth + 'px';
        setTimeout(() => {
          copyBtn.textContent = 'Copy';
          copyBtn.style.color = '';
          copyBtn.style.minWidth = '';
        }, 1200);
      });
    });
  }
});
