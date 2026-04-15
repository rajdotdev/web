// main.js – Handles copy‑to‑clipboard and simple reveal animations

document.addEventListener('DOMContentLoaded', () => {
  // Copy button functionality
  const copyButtons = document.querySelectorAll('.copy-btn');
  copyButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const text = btn.getAttribute('data-clipboard-text');
      navigator.clipboard.writeText(text).then(() => {
        // Temporary feedback
        const original = btn.textContent;
        btn.textContent = 'Copied!';
        btn.disabled = true;
        setTimeout(() => {
          btn.textContent = original;
          btn.disabled = false;
        }, 1500);
      }).catch(err => {
        console.error('Clipboard error:', err);
      });
    });
  });

  // Simple scroll‑reveal animation for script cards
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.script-card').forEach(card => {
    observer.observe(card);
  });
});
