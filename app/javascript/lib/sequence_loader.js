// The film, fetched before the document is shown.
//
// The plate is thousands of frames and the page prints one of them at a fixed
// edge; opened cold, the first seconds of scrolling read as a slideshow of
// whatever happened to arrive first. So the frames are fetched up front, a few
// at a time, behind a plain screen that counts them off, and the document is
// revealed when they are in hand. Once loaded they live in the browser cache,
// which is what lib/frame_sequence then scrubs.
//
// If this file never runs, the screen stays hidden and the page behaves exactly
// as it did before: nothing here is load-bearing.
const CONCURRENCY = 8;

export default class SequenceLoader {
  static attachAll(root = document) {
    const loaders = [];
    for (const stage of root.querySelectorAll("[data-sequence-stage]")) {
      const loader = new SequenceLoader(stage);
      if (loader.ready) loaders.push(loader);
    }
    return loaders;
  }

  constructor(stage) {
    this.stage = stage;
    this.screen = stage.querySelector("[data-sequence-loader]");
    this.output = stage.querySelector("[data-sequence-loader-value]");
    this.layer = stage.querySelector("[data-sequence-layer]");
    this.ready = Boolean(this.screen && this.layer);

    if (!this.ready) return;

    this.base = this.layer.getAttribute("data-sequence-base");
    this.count = parseInt(this.layer.getAttribute("data-sequence-count") || "0", 10);
    this.ready = Boolean(this.base && this.count);

    if (!this.ready) return;

    // Shown by script, never by markup, so a reader without it is never held
    // behind a screen that cannot lift.
    this.screen.hidden = false;
    this.stage.classList.add("is-loading");
    this.load();
  }

  framePath(number) {
    return `${this.base}/frame_${String(number).padStart(4, "0")}.webp`;
  }

  async load() {
    const queue = [];
    for (let number = 1; number <= this.count; number += 1) queue.push(number);

    let done = 0;
    const worker = async () => {
      while (queue.length > 0) {
        await this.claim(queue.shift());
        done += 1;
        if (done % 16 === 0) this.report(done);
      }
    };

    await Promise.all(
      Array.from({ length: Math.min(CONCURRENCY, queue.length) }, () => worker())
    );

    this.report(this.count);
    this.reveal();
  }

  claim(number) {
    return new Promise((resolve) => {
      const image = new Image();
      image.decoding = "async";
      image.addEventListener("load", resolve, { once: true });
      image.addEventListener("error", resolve, { once: true });
      image.src = this.framePath(number);
    });
  }

  report(done) {
    if (!this.output) return;
    this.output.textContent = `${Math.round((done / this.count) * 100)}%`;
  }

  reveal() {
    this.screen.hidden = true;
    this.stage.classList.remove("is-loading");
    this.stage.classList.add("is-loaded");
  }
}
