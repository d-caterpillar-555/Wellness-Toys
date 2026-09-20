// A scrubbed frame sequence: the reader's position in the page is the playhead.
//
// The markup is the whole contract.
//
//   [data-sequence-stage]           defines the scroll range - the element the
//                                   reader travels through
//   [data-sequence-layer]           one sequence of frames inside it, carrying
//     data-sequence-base            the folder the frames are in
//     data-sequence-count           how many there are
//     data-sequence-range           optional "from,to" of the stage's progress
//                                   this layer is live for (default 0,1)
//     [data-sequence-frame=current] the image being shown
//
// A stage can hold more than one layer, which is how the folio runs one study
// behind the first half of the document and another behind the second: each
// layer takes its own slice of the same progress and fades out beyond it.
//
// Two things make a scrub read as movement rather than as a slideshow:
//
//   * the playhead eases toward the scroll position in frame space, so a fast
//     wheel is followed rather than snapped at, and
//   * frames are fetched in passes - every sixteenth frame first, then every
//     eighth, and so on - so any position has a frame near it long before the
//     whole sequence has downloaded.
//
// The frame being shown is swapped in through a second plate that decodes
// first, and the swap itself is instant: a fade on the plate leaves both
// frames half transparent at the same moment during a fast scrub, which the
// reader sees as the page flashing through the figure. A reader who has asked
// for reduced motion gets one frame and fetches nothing beyond it.
const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
// How fast the playhead closes on the scroll position, and how far it may move
// in one frame. Without the cap a fast wheel moves the playhead dozens of
// frames per tick and the picture strobes; with it a hard scroll reads as
// motion that catches up. Both are deliberately slack now that the film is one
// long take: the kiss used to run past in a second on a flick of the wheel, so
// the playhead takes a smaller share of the gap each tick and is capped at
// three frames, which lets a hard scroll read as the film hurrying rather than
// as the film skipping.
const EASE = 0.08;
const MAX_STEP = 3;
const PASSES = [ 16, 8, 4, 2, 1 ];
const PASS_PAUSE = 260;

export default class FrameSequence {
  static attachAll(root = document) {
    const attached = [];
    for (const layer of root.querySelectorAll("[data-sequence-layer]")) {
      const sequence = new FrameSequence(layer);
      if (sequence.ready) attached.push(sequence);
    }
    return attached;
  }

  constructor(layer) {
    this.ready = false;
    this.layer = layer;
    this.stage = layer.closest("[data-sequence-stage]") || layer;
    this.current = layer.querySelector("[data-sequence-frame='current']");
    this.base = layer.getAttribute("data-sequence-base");
    this.count = parseInt(layer.getAttribute("data-sequence-count") || "0", 10);
    if (!this.current || !this.base || !this.count) return;

    const range = (layer.getAttribute("data-sequence-range") || "0,1").split(",").map(Number);
    this.from = Number.isFinite(range[0]) ? range[0] : 0;
    this.to = Number.isFinite(range[1]) ? range[1] : 1;
    this.ready = true;

    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    this.images = new Map();
    this.loaded = new Set();
    this.showing = 1;
    this.playhead = 1;
    this.target = 1;
    this.running = false;
    this.pending = false;
    this.generation = 0;
    this.visible = false;
    this.live = true;
    this.claimedAt = null;

    this.buffer = this.current.cloneNode(false);
    this.buffer.classList.remove("is-current");
    this.current.parentNode.appendChild(this.buffer);

    layer.classList.add("is-live");

    if (this.reduced) {
      this.claim(this.count);
      this.display(this.count);
      return;
    }

    this.preload();

    this.gate = new IntersectionObserver((entries) => {
      this.visible = entries.some((entry) => entry.isIntersecting);
      if (this.visible) this.request();
    }, { threshold: 0 });
    this.gate.observe(this.stage);

    window.addEventListener("scroll", () => this.request(), { passive: true });
    window.addEventListener("resize", () => this.request(), { passive: true });
  }

  framePath(number) {
    return `${this.base}/frame_${String(number).padStart(4, "0")}.webp`;
  }

  // Fetch, and remember which frames are decoded. decode() resolves before the
  // browser has to paint, which is the difference between a swap and a flicker.
  claim(number) {
    if (this.images.has(number)) return this.images.get(number);

    const image = new Image();
    image.decoding = "async";
    image.src = this.framePath(number);
    image.addEventListener("load", () => this.loaded.add(number), { once: true });
    if (typeof image.decode === "function") {
      image.decode().then(() => this.loaded.add(number)).catch(() => {});
    }

    this.images.set(number, image);
    return image;
  }

  preload() {
    const run = (pass) => {
      if (pass >= PASSES.length) return;

      const step = PASSES[pass];
      for (let number = 1; number <= this.count; number += step) this.claim(number);

      window.setTimeout(() => run(pass + 1), PASS_PAUSE);
    };

    run(0);
  }

  // The nearest frame that is ready. Scrubbing before the sequence has arrived
  // shows the closest thing there is rather than nothing.
  nearest(number) {
    if (this.loaded.has(number)) return number;

    let best = null;
    let closest = Infinity;
    for (const candidate of this.loaded) {
      const distance = Math.abs(candidate - number);
      if (distance < closest) {
        closest = distance;
        best = candidate;
      }
    }
    return best;
  }

  display(number) {
    if (number === null || number === this.showing) return;
    this.showing = number;

    const source = this.framePath(number);
    const generation = (this.generation += 1);
    this.buffer.src = source;

    const swap = () => {
      if (generation !== this.generation) return;

      this.current.classList.remove("is-current");
      this.buffer.classList.add("is-current");
      const previous = this.current;
      this.current = this.buffer;
      this.buffer = previous;
    };

    if (this.buffer.complete) {
      swap();
    } else {
      this.buffer.addEventListener("load", swap, { once: true });
    }
  }

  request() {
    if (this.pending || !this.visible) return;
    this.pending = true;
    requestAnimationFrame(() => {
      this.pending = false;
      if (this.visible) this.update();
    });
  }

  progress() {
    const rect = this.stage.getBoundingClientRect();
    const travel = Math.max(1, this.stage.offsetHeight - window.innerHeight);
    return clamp(-rect.top / travel, 0, 1);
  }

  update() {
    const progress = this.progress();
    const live = progress >= this.from && progress <= this.to;

    if (live !== this.live) {
      this.live = live;
      this.layer.classList.toggle("is-live", live);
    }
    if (!live) return;

    const local = clamp((progress - this.from) / Math.max(0.0001, this.to - this.from), 0, 1);
    this.target = 1 + local * (this.count - 1);
    this.lookahead();
    this.run();
  }

  // Frames the reader is about to need. Deliberately small: an earlier version
  // claimed thirty at a time on every scroll event, and the decodes were heavy
  // enough to stutter the scrub they were meant to smooth. This is a nudge
  // ahead, and the passes do the rest.
  lookahead() {
    if (this.claimedAt === this.target) return;
    this.claimedAt = this.target;

    const centre = Math.round(this.target);
    for (let offset = -3; offset <= 12; offset += 3) {
      const number = centre + offset;
      if (number >= 1 && number <= this.count) this.claim(number);
    }
  }

  // Ease the playhead toward the target and keep the loop alive until it has
  // caught up: a frame per wheel event reads as a jump cut.
  run() {
    if (this.running) return;
    this.running = true;

    const tick = () => {
      const difference = this.target - this.playhead;

      if (Math.abs(difference) < 0.4) {
        this.playhead = this.target;
        this.running = false;
      } else {
        const step = clamp(difference * EASE, -MAX_STEP, MAX_STEP);
        this.playhead += step;
        requestAnimationFrame(tick);
      }

      this.display(this.nearest(Math.round(this.playhead)));
    };

    requestAnimationFrame(tick);
  }
}
