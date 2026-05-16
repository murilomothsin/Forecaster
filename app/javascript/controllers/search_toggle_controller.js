import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["zipFields", "cityFields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const mode = this.element.querySelector("input[name='search_mode']:checked").value
    this.zipFieldsTarget.classList.toggle("hidden", mode !== "zip")
    this.cityFieldsTarget.classList.toggle("hidden", mode !== "city")

    const inactive = mode === "zip" ? this.cityFieldsTarget : this.zipFieldsTarget
    inactive.querySelectorAll("input").forEach(input => input.value = "")
  }
}
