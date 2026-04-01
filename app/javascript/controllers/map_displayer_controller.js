import L from "leaflet"
import { Controller } from "@hotwired/stimulus"

// Read-only map showing the seller's meetup pin.
export default class extends Controller {
    static targets = ["map"]
    static values = { lat: Number, lng: Number, note: String }

    connect() {
        this.map = L.map(this.mapTarget).setView([this.latValue, this.lngValue], 16)
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "&copy; OpenStreetMap contributors",
            maxZoom: 19
        }).addTo(this.map)

        const marker = L.marker([this.latValue, this.lngValue]).addTo(this.map)
        if (this.noteValue) {
            marker.bindPopup(this.noteValue).openPopup()
        }
    }

    disconnect() {
        if (this.map) this.map.remove()
    }
}
