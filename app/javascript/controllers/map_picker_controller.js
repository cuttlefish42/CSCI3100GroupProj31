import { Controller } from "@hotwired/stimulus"

// Seller clicks the map to place a meetup pin.
// Writes lat/lng into hidden form fields.
export default class extends Controller {
    static targets = ["map", "lat", "lng"]
    static values = { lat: { type: Number, default: 22.4196 }, lng: { type: Number, default: 114.2068 } }

    connect() {
        const hasPin = this.latValue !== 22.4196 || this.lngValue !== 114.2068
        const center = hasPin ? [this.latValue, this.lngValue] : [22.4196, 114.2068]

        this.map = L.map(this.mapTarget).setView(center, 16)
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "&copy; OpenStreetMap contributors",
            maxZoom: 19
        }).addTo(this.map)

        this.marker = null
        if (hasPin) {
            this.marker = L.marker(center).addTo(this.map)
        }

        this.map.on("click", (e) => {
            const { lat, lng } = e.latlng
            if (this.marker) {
                this.marker.setLatLng([lat, lng])
            } else {
                this.marker = L.marker([lat, lng]).addTo(this.map)
            }
            this.latTarget.value = lat.toFixed(8)
            this.lngTarget.value = lng.toFixed(8)
        })
    }

    disconnect() {
        if (this.map) this.map.remove()
    }
}