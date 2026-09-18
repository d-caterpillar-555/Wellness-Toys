// figure: a drawn figure that changes pose as the page scrolls.
//
// The figure is a small skeleton - thirteen joints - and five key poses. Scroll
// progress across the stage is mapped onto the poses and the joints are
// interpolated between the two nearest, so the movement is continuous rather
// than a series of jumps.
//
// Cost is kept to one attribute write per joint per frame, and the frame loop
// only runs while the stage is on screen. The listener is passive and sets a
// dirty flag; the work happens in requestAnimationFrame, never in the handler,
// so a fast wheel cannot stall the main thread.
const POSES = [
  {
    name: "stand",
    head: [ 100, 62 ], neck: [ 100, 88 ],
    shoulderL: [ 77, 104 ], shoulderR: [ 123, 104 ],
    elbowL: [ 74, 162 ], elbowR: [ 126, 162 ],
    wristL: [ 72, 218 ], wristR: [ 128, 218 ],
    hipL: [ 88, 206 ], hipR: [ 112, 206 ],
    kneeL: [ 84, 292 ], kneeR: [ 116, 292 ],
    ankleL: [ 82, 372 ], ankleR: [ 118, 372 ]
  },
  {
    name: "reach",
    head: [ 100, 58 ], neck: [ 100, 84 ],
    shoulderL: [ 77, 100 ], shoulderR: [ 123, 100 ],
    elbowL: [ 68, 158 ], elbowR: [ 140, 84 ],
    wristL: [ 60, 214 ], wristR: [ 152, 22 ],
    hipL: [ 88, 204 ], hipR: [ 112, 204 ],
    kneeL: [ 84, 292 ], kneeR: [ 118, 292 ],
    ankleL: [ 80, 372 ], ankleR: [ 122, 372 ]
  },
  {
    name: "fold",
    head: [ 102, 72 ], neck: [ 100, 96 ],
    shoulderL: [ 77, 110 ], shoulderR: [ 123, 110 ],
    elbowL: [ 86, 168 ], elbowR: [ 114, 168 ],
    wristL: [ 112, 144 ], wristR: [ 88, 144 ],
    hipL: [ 88, 210 ], hipR: [ 112, 210 ],
    kneeL: [ 84, 294 ], kneeR: [ 116, 294 ],
    ankleL: [ 82, 372 ], ankleR: [ 118, 372 ]
  },
  {
    name: "rest",
    head: [ 100, 62 ], neck: [ 100, 88 ],
    shoulderL: [ 77, 104 ], shoulderR: [ 123, 104 ],
    elbowL: [ 62, 152 ], elbowR: [ 138, 152 ],
    wristL: [ 88, 206 ], wristR: [ 112, 206 ],
    hipL: [ 88, 206 ], hipR: [ 112, 206 ],
    kneeL: [ 82, 292 ], kneeR: [ 120, 292 ],
    ankleL: [ 78, 372 ], ankleR: [ 124, 372 ]
  },
  {
    name: "open",
    head: [ 100, 60 ], neck: [ 100, 86 ],
    shoulderL: [ 77, 102 ], shoulderR: [ 123, 102 ],
    elbowL: [ 54, 84 ], elbowR: [ 146, 84 ],
    wristL: [ 22, 60 ], wristR: [ 178, 60 ],
    hipL: [ 88, 206 ], hipR: [ 112, 206 ],
    kneeL: [ 84, 290 ], kneeR: [ 116, 290 ],
    ankleL: [ 80, 372 ], ankleR: [ 120, 372 ]
  }
];

const NS = "http://www.w3.org/2000/svg";
const LIMBS = [
  [ "shoulderL", "elbowL", "wristL" ],
  [ "shoulderR", "elbowR", "wristR" ],
  [ "hipL", "kneeL", "ankleL" ],
  [ "hipR", "kneeR", "ankleR" ]
];

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const smooth = (t) => t * t * (3 - 2 * t);
const mix = (a, b, t) => a + (b - a) * t;

function mixPose(a, b, t) {
  const pose = {};
  for (const key of Object.keys(a)) {
    if (key === "name") continue;
    pose[key] = [ mix(a[key][0], b[key][0], t), mix(a[key][1], b[key][1], t) ];
  }
  return pose;
}

export default class Figure {
  constructor(root = document) {
    this.stage = root.querySelector("[data-figure-stage]");
    this.svg = root.querySelector("[data-figure-svg]");
    if (!this.stage || !this.svg) return;

    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    this.build();

    if (this.reduced) {
      // One composed pose, no performance. The pose still reads as a figure.
      this.draw(this.pose(1.0), 1.0);
      return;
    }

    this.visible = false;
    this.pending = false;

    this.gate = new IntersectionObserver((entries) => {
      this.visible = entries.some((entry) => entry.isIntersecting);
      if (this.visible) this.request();
    }, { threshold: 0 });
    this.gate.observe(this.stage);

    window.addEventListener("scroll", () => this.request(), { passive: true });
    window.addEventListener("resize", () => this.request(), { passive: true });

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

    this.request();
  }

  // Build the skeleton once; every frame after this only writes attributes.
  build() {
    const group = (name) => {
      const node = document.createElementNS(NS, "g");
      node.setAttribute("class", name);
      this.svg.appendChild(node);
      return node;
    };

    this.shadow = document.createElementNS(NS, "ellipse");
    this.shadow.setAttribute("class", "fig-shadow");
    this.shadow.setAttribute("cx", "100");
    this.shadow.setAttribute("cy", "378");
    this.shadow.setAttribute("rx", "42");
    this.shadow.setAttribute("ry", "7");
    this.svg.appendChild(this.shadow);

    this.glow = group("fig-glow");
    this.rim = group("fig-rim");
    this.body = group("fig-body");

    this.torso = {
      glow: document.createElementNS(NS, "path"),
      rim: document.createElementNS(NS, "path"),
      body: document.createElementNS(NS, "path")
    };
    this.glow.appendChild(this.torso.glow);
    this.rim.appendChild(this.torso.rim);
    this.body.appendChild(this.torso.body);

    this.head = {
      glow: document.createElementNS(NS, "circle"),
      rim: document.createElementNS(NS, "circle"),
      body: document.createElementNS(NS, "circle")
    };
    const radii = { glow: 26, rim: 19, body: 17 };
    for (const layer of [ "glow", "rim", "body" ]) {
      this.head[layer].setAttribute("r", String(radii[layer]));
      this[layer === "body" ? "body" : layer].appendChild(this.head[layer]);
    }

    this.limbs = LIMBS.map(([ from, joint, to ]) => {
      const limb = {
        from,
        joint,
        to,
        glow: document.createElementNS(NS, "path"),
        rim: document.createElementNS(NS, "path"),
        body: document.createElementNS(NS, "path")
      };
      this.glow.appendChild(limb.glow);
      this.rim.appendChild(limb.rim);
      this.body.appendChild(limb.body);
      return limb;
    });
  }

  request() {
    if (this.pending || !this.visible) return;
    this.pending = true;
    requestAnimationFrame(() => {
      this.pending = false;
      if (this.visible) this.update();
    });
  }

  update() {
    const rect = this.stage.getBoundingClientRect();
    const travel = Math.max(1, this.stage.offsetHeight - window.innerHeight);
    this.draw(this.pose(clamp(-rect.top / travel, 0, 1)), clamp(-rect.top / travel, 0, 1));
  }

  pose(progress) {
    const scaled = progress * (POSES.length - 1);
    const index = Math.min(POSES.length - 2, Math.floor(scaled));
    const t = smooth(clamp(scaled - index, 0, 1));
    return mixPose(POSES[index], POSES[Math.min(index + 1, POSES.length - 1)], t);
  }

  draw(pose, progress) {
    // A slow sway, so a still reader still sees the figure breathe. It is
    // largest halfway through a pose and absent at the keyframes themselves.
    const sway = Math.sin(progress * Math.PI * 5) * 1.8;

    const point = (joint) => {
      const [ x, y ] = pose[joint];
      const weight = [ "head", "neck", "shoulderL", "shoulderR" ].includes(joint) ? sway : sway * 0.5;
      return [ x + weight, y ];
    };

    const line = (from, joint, to, offset = 0) => {
      const [ ax, ay ] = point(from);
      const [ bx, by ] = point(joint);
      const [ cx, cy ] = point(to);
      return `M ${ax + offset} ${ay + offset} L ${bx + offset} ${by + offset} L ${cx + offset} ${cy + offset}`;
    };

    const [ hx, hy ] = point("head");
    this.head.glow.setAttribute("cx", hx);
    this.head.glow.setAttribute("cy", hy);
    this.head.rim.setAttribute("cx", hx - 1.5);
    this.head.rim.setAttribute("cy", hy - 1.5);
    this.head.body.setAttribute("cx", hx);
    this.head.body.setAttribute("cy", hy);

    const torso = () => {
      const [ slx, sly ] = point("shoulderL");
      const [ srx, sry ] = point("shoulderR");
      const [ hlx, hly ] = point("hipL");
      const [ hrx, hry ] = point("hipR");
      const midX = (hlx + hrx) / 2;
      return `M ${slx} ${sly} Q ${midX} ${sly + 26} ${hlx} ${hly} L ${hrx} ${hry} Q ${midX} ${sry + 26} ${srx} ${sry} Z`;
    };

    const path = torso();
    this.torso.glow.setAttribute("d", path);
    this.torso.rim.setAttribute("d", path);
    this.torso.body.setAttribute("d", path);

    for (const limb of this.limbs) {
      limb.glow.setAttribute("d", line(limb.from, limb.joint, limb.to));
      limb.rim.setAttribute("d", line(limb.from, limb.joint, limb.to, -1.5));
      limb.body.setAttribute("d", line(limb.from, limb.joint, limb.to));
    }

    const [ alx ] = point("ankleL");
    const [ arx ] = point("ankleR");
    const span = Math.abs(arx - alx);
    this.shadow.setAttribute("rx", String(26 + span));
    this.shadow.setAttribute("opacity", String(0.5 - Math.min(0.25, span / 200)));
  }
}

new Figure();
