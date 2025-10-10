document.addEventListener('DOMContentLoaded', function () {
  const mainTitle = document.querySelector('h1');
  const form = document.querySelector('form');

  // Create preview heading and copy button
  const headingContainer = document.createElement('div');
  
  const previewHeading = document.createElement('h2');
  previewHeading.textContent = 'Your Command';
  previewHeading.style.display = 'inline-block';

  const copyBtn = document.createElement('button');
  copyBtn.type = 'button';
  copyBtn.textContent = 'Copy';
  copyBtn.title = 'Copy to clipboard';
  copyBtn.style.display = 'inline-block';
  copyBtn.style.marginLeft = '1em';
  copyBtn.style.border = '1px solid #888';
  copyBtn.style.borderRadius = '4px';
  copyBtn.style.padding = '0.3em 1em';
  copyBtn.style.cursor = 'pointer';

  headingContainer.appendChild(previewHeading);
  headingContainer.appendChild(copyBtn);

  // Create preview box
  const previewBox = document.createElement('div');
  previewBox.id = 'live-command-preview';
  previewBox.style.background = '#222';
  previewBox.style.color = '#eee';
  previewBox.style.padding = '1em';
  previewBox.style.borderRadius = '6px';
  previewBox.style.fontFamily = 'monospace';
  previewBox.style.whiteSpace = 'pre-wrap';
  previewBox.style.position = 'relative';
  previewBox.style.marginTop = '0.2em';
  previewBox.style.marginBottom = '3.0em';

  // Insert elements after form
  if (form && form.parentNode) {
    form.parentNode.insertBefore(headingContainer, form.nextSibling);
    form.parentNode.insertBefore(previewBox, headingContainer.nextSibling);
  }

  function buildCommand() {
    let cmd = mainTitle ? mainTitle.textContent.trim() : '';
    if (!form) return cmd;

    // Collect environment variables as prefix
    let envParts = [];
    let cliParts = [cmd];
    Array.from(form.elements).forEach(el => {
      if (!el.name || el.type === 'fieldset' || el.type === 'legend') return;

      // Environment variables
      const isEnvVar = (
        el.type === 'text' &&
        !el.name.startsWith('--') &&
        !el.name.startsWith('-') &&
        (
          el.closest('fieldset')?.querySelector('legend')?.textContent === 'Environment Variables' ||
          el.closest('fieldset')?.querySelector('legend')?.textContent === 'Parent Environment Variables'
        )
      );
      if (isEnvVar) {
        if (el.value) {
          let envId = el.id.startsWith('parent-') ? el.id.slice(7) : el.id;
          envParts.push(`${envId}="${el.value}"`);
        }
        return;
      }

      // Checkbox
      if (el.type === 'checkbox' && el.checked) {
        cliParts.push(el.id);
        return;
      }

      // Select
      if (el.tagName === 'SELECT') {
        if (el.multiple) {
          Array.from(el.selectedOptions).forEach(opt => {
            if (opt.value) cliParts.push(el.id, opt.value);
          });
        } else if (el.value) {
          cliParts.push(el.id, el.value);
        }
        return;
      }

      // Text input
      if (el.type === 'text' && el.value) {
        if (el.name.startsWith('--') || el.name.startsWith('-')) {
          cliParts.push(el.id, el.value);
        } else {
          cliParts.push(el.value);
        }
      }
    });

    return (envParts.length ? envParts.join(' ') + ' ' : '') + cliParts.join(' ');
  }

  function updatePreview() {
    previewBox.textContent = buildCommand();
  }

  copyBtn.addEventListener('click', () => {
    const cmdText = buildCommand();
    navigator.clipboard.writeText(cmdText).then(() => {
      copyBtn.textContent = '✔️ Copied!';
      setTimeout(() => {
        copyBtn.textContent = 'Copy';
      }, 1200);
    });
  });

  if (form) {
    form.addEventListener('input', updatePreview);
    form.addEventListener('change', updatePreview);
    updatePreview();
  }
});