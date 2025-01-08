import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["files"];

  addFile(event) {
    const originalInput = event.target;
    const originalParent = originalInput.parentNode;
    const selectedFile = document.createElement("div");
    selectedFile.className = "selected-file";
    selectedFile.append(originalInput);
    var labelNode = document.createElement("label");
    var textElement = document.createTextNode(originalInput.files[0].name);
    labelNode.appendChild(textElement);
    selectedFile.appendChild(labelNode);
    this.filesTarget.append(selectedFile);
    const newInput = originalInput.cloneNode();
    newInput.value = "";
    originalParent.append(newInput);
  }
}
