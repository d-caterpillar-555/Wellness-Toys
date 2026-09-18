// plan: the marker follows the room the visitor is considering.
//
// The plan is a drawing, and a drawing has a "you are here". Pointing at or
// tabbing to a room moves the marker to it and prints the room's name and
// count in the readout, so the plan answers before it navigates. Nothing else
// happens on hover, and the marker is decorative - the rooms are real links.
export default class Plan {
  constructor(root = document) {
    this.board = root.querySelector("[data-plan-board]");
    if (!this.board) return;

    this.marker = this.board.querySelector("[data-plan-marker]");
    this.readout = root.querySelector("[data-plan-readout]");
    this.rooms = Array.from(this.board.querySelectorAll("[data-plan-room]"));
    if (this.rooms.length === 0) return;

    for (const room of this.rooms) {
      room.addEventListener("pointerenter", () => this.point(room));
      room.addEventListener("focus", () => this.point(room));
    }
  }

  point(room) {
    const { x, y, name, count } = room.dataset;
    if (this.marker && x && y) {
      this.marker.setAttribute("transform", `translate(${x} ${y})`);
    }
    if (this.readout) {
      this.readout.textContent = `${name} - ${count}`;
    }
  }
}

new Plan();
