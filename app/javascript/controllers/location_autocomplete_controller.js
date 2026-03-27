import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "country"]

  connect() {
    this.mapboxKey = this.element.dataset.mapboxKey || ""
    this.timer = null
    this.selectedIndex = -1
    this.places = []
    this.cache = {}

    this.handleClickOutside = this.close.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase()

    clearTimeout(this.timer)

    if (!this.mapboxKey) {
      this.hide()
      return
    }

    if (query.length < 2) {
      this.hide()
      return
    }

    this.timer = setTimeout(() => {

      if (this.cache[query]) {
        this.renderResults(query, this.cache[query])
        return
      }

      this.fetchLocations(query)

    }, 400)
  }

  fetchLocations(query) {
    const url =
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json` +
      `?types=place&limit=5&language=pt&proximity=-46.63,-23.55&access_token=${this.mapboxKey}`

    fetch(url)
      .then(r => r.json())
      .then(data => {

        const results = data.features.map(feature => {
          const city = feature.text
          const label = feature.place_name

          const country =
            feature.context?.find(c => c.id.startsWith("country"))?.text

          return { city, country, label }
        })

        this.cache[query] = results

        this.renderResults(query, results)
      })
      .catch(() => this.hide())
  }

  renderResults(query, places) {
    this.resultsTarget.innerHTML = ""
    this.places = places
    this.selectedIndex = -1

    if (!places || places.length === 0) {
      this.hide()
      return
    }

    places.forEach((place, index) => {
      const li = document.createElement("li")

      li.innerHTML = this.highlight(place.label, query)

      li.className =
        "px-4 py-2 cursor-pointer hover:bg-slate-100 dark:hover:bg-slate-700"

      li.addEventListener("click", () => {
        this.select(place.city, place.country)
      })

      this.resultsTarget.appendChild(li)
    })

    this.resultsTarget.classList.remove("hidden")
  }

  keydown(event) {
    if (this.places.length === 0) return

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.selectedIndex =
        (this.selectedIndex + 1) % this.resultsTarget.children.length
      this.updateSelection()
    }

    if (event.key === "ArrowUp") {
      event.preventDefault()
      this.selectedIndex =
        (this.selectedIndex - 1 + this.resultsTarget.children.length) %
        this.resultsTarget.children.length
      this.updateSelection()
    }

    if (event.key === "Enter") {
      event.preventDefault()

      if (this.selectedIndex >= 0) {
        const place = this.places[this.selectedIndex]
        this.select(place.city, place.country)
      }
    }

    if (event.key === "Escape") {
      this.hide()
    }
  }

  updateSelection() {
    const items = this.resultsTarget.children

    Array.from(items).forEach((el, i) => {
      const active = i === this.selectedIndex

      el.classList.toggle("bg-slate-200", active)
      el.classList.toggle("dark:bg-slate-600", active)
    })
  }

  select(city, country) {
    this.inputTarget.value = city

    if (this.hasCountryTarget) {
      this.countryTarget.value = country
    }

    this.hide()
  }

  highlight(text, query) {
    const regex = new RegExp(`(${query})`, "gi")
    return text.replace(regex, "<strong>$1</strong>")
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  hide() {
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
  }
}
