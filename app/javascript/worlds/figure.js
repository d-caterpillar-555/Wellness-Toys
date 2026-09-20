import FrameSequence from "lib/frame_sequence";

// figure: the world's figure is a sequence of rendered frames, and the rail
// knows which chapter the reader is in.
//
// The scrubbing itself is shared with the folio, where the same study hangs as
// a plate: see lib/frame_sequence. What belongs to this world is the rail and
// the chapter marking, which is what tells the reader where the playhead is.
export default class Figure {
  constructor(root = document) {
    this.watchChapters(root);
  }

  watchChapters(root) {
    this.chapterObserver = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          const name = entry.target.getAttribute("data-pose");
          for (const link of root.querySelectorAll("[data-figure-link]")) {
            if (link.getAttribute("data-pose") === name) {
              link.setAttribute("aria-current", "true");
            } else {
              link.removeAttribute("aria-current");
            }
          }
        }
      },
      { rootMargin: "-45% 0px -45% 0px", threshold: 0 }
    );

    for (const chapter of root.querySelectorAll("[data-pose]")) {
      if (chapter.tagName === "SECTION") this.chapterObserver.observe(chapter);
    }
  }
}

new Figure();
FrameSequence.attachAll();
