 class Divider extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
 
    return node;
  }
}
Divider.blotName = "divider";
Divider.tagName = "HR";
