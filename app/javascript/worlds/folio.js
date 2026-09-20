import FrameSequence from "lib/frame_sequence";
import SequenceLoader from "lib/sequence_loader";

// folio: the index knows where the reader is, and says so.
//
// The document is one page, so the index is the only navigation there is. Two
// jobs: mark the section the reader is in, and draw how far through the
// document they have come. Both come from one IntersectionObserver over the
// sections - there is no scroll listener anywhere in this file.
//
// The plate is a third job, borrowed from the figure world: the frames of a
// rendered study advance with the reader's progress past it
// (lib/frame_sequence). The film is thousands of frames, so it is fetched
// before the document is shown, behind a screen that counts it off
// (lib/sequence_loader) - the page must never open onto a half-loaded plate.
export default class Folio {
  constructor(root = document) {
    this.sections = Array.from(root.querySelectorAll("[data-folio-section]"))
    this.links = new Map()

    for (const link of root.querySelectorAll("[data-folio-link]")) {
      const id = link.getAttribute("href")?.slice(1)
      if (id) this.links.set(id, link)
    }

    if (this.sections.length === 0 || this.links.size === 0) return

    this.progress = root.querySelector("[data-folio-progress]")
    this.walked = new Set()

    this.observer = new IntersectionObserver(
      (entries) => this.onIntersect(entries),
      { rootMargin: "-15% 0px -70% 0px", threshold: 0 }
    )
    for (const section of this.sections) this.observer.observe(section)

    this.mark(this.sections[0].id)
  }

  onIntersect(entries) {
    const crossed = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)

    if (crossed.length > 0) {
      this.mark(crossed[0].target.id)
    } else {
      // Nothing is crossing the reading line: keep the deepest section that
      // has already been passed, so the index never goes blank.
      const passed = this.sections.filter(
        (section) => section.getBoundingClientRect().top < window.innerHeight * 0.3
      )
      if (passed.length > 0) this.mark(passed[passed.length - 1].id)
    }

    for (const entry of entries) {
      if (entry.isIntersecting) this.walked.add(entry.target.id)
    }
    if (this.progress) {
      const share = (this.walked.size / this.sections.length) * 100
      this.progress.style.setProperty("--walked", `${Math.round(share)}%`)
    }
  }

  mark(id) {
    for (const [key, link] of this.links) {
      if (key === id) {
        link.setAttribute("aria-current", "true")
      } else {
        link.removeAttribute("aria-current")
      }
    }
  }
}

new Folio()
SequenceLoader.attachAll()
FrameSequence.attachAll()
