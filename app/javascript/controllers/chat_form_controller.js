import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="chat-form"
export default class extends Controller {
    reset(event) {
        if (event.detail.success) {
            this.element.reset();
        }
    }

    submitOnEnter(event) {
        // Trigger submit if Enter is pressed without the Shift key
        if (event.key === "Enter" && !event.shiftKey) {
            event.preventDefault(); // Prevent a new line from being typed
            this.element.requestSubmit(); // Properly triggers the Turbo form submission
        }
    }
}
