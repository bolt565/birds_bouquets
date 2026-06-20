import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    clientSecret: String,
    publishableKey: String,
    confirmUrl: String
  }

  connect() {
    if (!this.publishableKeyValue) return

    this.stripe = Stripe(this.publishableKeyValue)
    const elements = this.stripe.elements()

    this.cardElement = elements.create("card", {
      style: {
        base: {
          fontSize: "14px",
          color: "#111827",
          "::placeholder": { color: "#9ca3af" }
        }
      }
    })
    this.cardElement.mount("#card-element")

    this.cardElement.on("change", (event) => {
      const errorEl = document.getElementById("card-error")
      if (event.error) {
        errorEl.textContent = event.error.message
        errorEl.classList.remove("hidden")
      } else {
        errorEl.classList.add("hidden")
      }
    })

    this.element.addEventListener("submit", this.handleSubmit.bind(this))
  }

  async handleSubmit(event) {
    event.preventDefault()
    this.setLoading(true)

    const { error, paymentIntent } = await this.stripe.confirmCardPayment(this.clientSecretValue, {
      payment_method: { card: this.cardElement }
    })

    if (error) {
      const errorEl = document.getElementById("card-error")
      errorEl.textContent = error.message
      errorEl.classList.remove("hidden")
      this.setLoading(false)
    } else if (paymentIntent && paymentIntent.status === "succeeded") {
      const csrfToken = document.querySelector("input[name='authenticity_token']")?.value
      const form = document.createElement("form")
      form.method = "POST"
      form.action = this.confirmUrlValue

      const tokenField = document.createElement("input")
      tokenField.type = "hidden"
      tokenField.name = "authenticity_token"
      tokenField.value = csrfToken
      form.appendChild(tokenField)

      document.body.appendChild(form)
      form.submit()
    }
  }

  setLoading(loading) {
    const btn = document.getElementById("submit-btn")
    const text = document.getElementById("btn-text")
    const spinner = document.getElementById("btn-loading")
    btn.disabled = loading
    text.classList.toggle("hidden", loading)
    spinner.classList.toggle("hidden", !loading)
  }
}
