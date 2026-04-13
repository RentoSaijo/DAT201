const toggle = document.querySelector("[data-nav-toggle]");
const nav = document.querySelector("[data-nav]");

if (toggle && nav) {
  toggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("open");
    toggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      nav.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    });
  });
}

const carousels = document.querySelectorAll("[data-carousel]");

carousels.forEach((carousel) => {
  const slides = Array.from(carousel.querySelectorAll("[data-slide]"));
  const dots = Array.from(carousel.querySelectorAll("[data-dot]"));

  if (!slides.length) {
    return;
  }

  let activeIndex = slides.findIndex((slide) => slide.classList.contains("is-active"));
  if (activeIndex === -1) {
    activeIndex = 0;
    slides[0].classList.add("is-active");
  }

  const setActive = (nextIndex) => {
    slides.forEach((slide, index) => {
      slide.classList.toggle("is-active", index === nextIndex);
    });

    dots.forEach((dot, index) => {
      dot.classList.toggle("is-active", index === nextIndex);
      dot.setAttribute("aria-pressed", String(index === nextIndex));
    });

    activeIndex = nextIndex;
  };

  dots.forEach((dot, index) => {
    dot.addEventListener("click", () => setActive(index));
  });

  if (slides.length > 1) {
    window.setInterval(() => {
      setActive((activeIndex + 1) % slides.length);
    }, 5000);
  }
});
