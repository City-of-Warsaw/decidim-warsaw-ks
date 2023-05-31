// const ATTRIBUTES = ["alt", "height", "width"];

function sanitize(url, protocols) {
  const anchor = document.createElement("a");
  anchor.href = url;
  const protocol = anchor.href.slice(0, anchor.href.indexOf(":"));
  return protocols.indexOf(protocol) > -1;
}

class ExtendedVideo extends Quill.import("blots/block/embed") {
  static create(value) {
    let node = super.create(value);
    node.setAttribute("contenteditable", false);
    node.setAttribute("controls", true);
    node.setAttribute("data-setup", '{ "fluid": true }');

    if (typeof value === "object") {
      if (value.posterUrl) {
        node.setAttribute("poster", value.posterUrl);
      }

      const mainSource = document.createElement("source");
      mainSource.setAttribute("src", this.sanitize(value.url));
      mainSource.setAttribute("type", value.mimetype);
      node.appendChild(mainSource);

      if (value.descriptionsTrackUrl) {
        const descriptionsTrack = document.createElement("track");
        descriptionsTrack.setAttribute("kind", "descriptions");
        descriptionsTrack.setAttribute(
          "src",
          this.sanitize(value.descriptionsTrackUrl)
        );
        descriptionsTrack.setAttribute("srclang", "pl");
        descriptionsTrack.setAttribute("label", "Polski");
        node.appendChild(descriptionsTrack);
      }

      if (value.subtitlesTrackUrl) {
        const subtitlesTrack = document.createElement("track");
        subtitlesTrack.setAttribute("kind", "subtitles");
        subtitlesTrack.setAttribute(
          "src",
          this.sanitize(value.subtitlesTrackUrl)
        );
        subtitlesTrack.setAttribute("srclang", "pl");
        subtitlesTrack.setAttribute("label", "Polski");
        node.appendChild(subtitlesTrack);
      }

      if (value.captionsTrackUrl) {
        const captionsTrack = document.createElement("track");
        captionsTrack.setAttribute("kind", "captions");
        captionsTrack.setAttribute(
          "src",
          this.sanitize(value.captionsTrackUrl)
        );
        captionsTrack.setAttribute("srclang", "pl");
        captionsTrack.setAttribute("label", "Polski");
        node.appendChild(captionsTrack);
      }
    }

    return node;
  }

  static formats(domNode) {
    return ["height", "width"].reduce(function (formats, attribute) {
      if (domNode.hasAttribute(attribute)) {
        formats[attribute] = domNode.getAttribute(attribute);
      }
      return formats;
    }, {});
  }

  static sanitize(url) {
    return sanitize(url, ["http", "https", "data"]) ? url : "//:0";
  }

  static value(domNode) {
    const value = {
      posterUrl: domNode.getAttribute("poster"),
    };

    const mainSource = domNode.querySelector("source");

    if (mainSource) {
      value.url = mainSource.getAttribute("src");
      value.mimetype = mainSource.getAttribute("type");
    }

    const descriptionsTrack = domNode.querySelector(
      'track[kind="descriptions"]'
    );
    if (descriptionsTrack) {
      value.descriptionsTrackUrl = descriptionsTrack.getAttribute("src");
    }

    const subtitlesTrack = domNode.querySelector('track[kind="subtitles"]');
    if (subtitlesTrack) {
      value.subtitlesTrackUrl = subtitlesTrack.getAttribute("src");
    }

    const captionsTrack = domNode.querySelector('track[kind="captions"]');
    if (captionsTrack) {
      value.captionsTrackUrl = captionsTrack.getAttribute("src");
    }

    return value;
  }

  format(name, value) {
    if (ATTRIBUTES.indexOf(name) > -1) {
      if (value) {
        this.domNode.setAttribute(name, value);
      } else {
        this.domNode.removeAttribute(name);
      }
    } else {
      super.format(name, value);
    }
  }
}
ExtendedVideo.blotName = "extended-video";
ExtendedVideo.className = "video-js";
ExtendedVideo.tagName = "VIDEO"; 
