#import "@preview/finite:0.5.1"
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 1.5cm)
#set text(size: 10pt, font: "New Computer Modern")

#let seller-color = rgb("#e74c3c")
#let buyer-color = rgb("#2980b9")
#let item-color = rgb("#27ae60")

#align(center)[
  = Offer States
  States and transitions for `Offer` model (`app/models/offer.rb`) \
  Routes defined under `resources :offers` in `config/routes.rb`

  #v(0.2cm)
  #set text(size: 9pt)
  #box(inset: 4pt, radius: 3pt, stroke: 0.5pt + luma(200))[
    #text(fill: seller-color)[---] Seller action
    #h(1cm)
    #text(fill: buyer-color)[---] Buyer action
  ]
]

#v(0.5cm)

#let seller-label(body) = text(size: 8pt, font: "DejaVu Sans Mono", fill: seller-color, body)
#let buyer-label(body) = text(size: 8pt, font: "DejaVu Sans Mono", fill: buyer-color, body)

#cetz.canvas({
  import cetz.draw: set-style
  import finite.draw: loop, state, transition

  set-style(
    state: (radius: 0.9),
    transition: (curve: 0.6),
  )

  // states
  state((0, 0), "pending", label: "Pending", initial: left)
  state((10, 0), "countered", label: "Countered")
  state((16, 5), "accepted", label: "Accepted")
  state((16, -5), "rejected", label: "Rejected", final: true)
  state((24, 5), "completed", label: "Completed", final: true)

  // seller actions in red
  transition("pending", "accepted", label: seller-label[POST .../acceptance], curve: 0, stroke: seller-color)
  transition("pending", "rejected", label: seller-label[POST .../rejection], curve: 0, stroke: seller-color)
  transition("pending", "countered", label: seller-label[POST .../counter], curve: 0.5, stroke: seller-color)

  // buyers actions in blue
  transition("countered", "accepted", label: buyer-label[POST .../counter_acceptance], curve: 0, stroke: buyer-color)
  transition("countered", "rejected", label: buyer-label[POST .../counter_rejection], curve: 0, stroke: buyer-color)
  transition("countered", "pending", label: buyer-label[PATCH .../offers/:id], curve: 0.5, stroke: buyer-color)
  loop("pending", label: buyer-label[PATCH .../offers/:id], anchor: bottom, stroke: buyer-color)
  transition("accepted", "completed", label: buyer-label[POST .../review (buyer)], curve: 0, stroke: buyer-color)
})

#v(1cm)

#align(center)[
  = Item States
  States and transitions for `Item` model (`app/models/item.rb`) \
  Triggered as side-effects of offer actions

  #v(0.2cm)
  #set text(size: 9pt)
  #box(inset: 4pt, radius: 3pt, stroke: 0.5pt + luma(200))[
    #text(fill: item-color)[---] Triggered by offer transition
  ]
]

#v(0.5cm)

#let item-label(body) = text(size: 8pt, font: "DejaVu Sans Mono", fill: item-color, body)

#cetz.canvas({
  import cetz.draw: set-style
  import finite.draw: state, transition

  set-style(
    state: (radius: 0.9),
    transition: (curve: 0.6),
  )

  state((0, 0), "available", label: "Available", initial: left)
  state((10, 0), "reserved", label: "Reserved")
  state((20, 0), "sold", label: "Sold", final: true)

  transition("available", "reserved", label: item-label[Offer accepted], curve: 0, stroke: item-color)
  transition("reserved", "sold", label: item-label[Buyer submits review], curve: 0, stroke: item-color)
})

#v(1cm)

#align(center)[
  #set text(size: 9pt)
  #table(
    columns: 5,
    align: (left, left, left, left, left),
    stroke: 0.5pt + luma(180),
    inset: 6pt,
    table.header([*Route*], [*Offer Transition*], [*Item Side-effect*], [*Controller*], [*Actor*]),
    [`POST /items/:item_id/offers`],
    [_(new)_ #sym.arrow Pending],
    [—],
    [`OffersController#create`],
    text(fill: buyer-color)[Buyer],

    [`POST .../offers/:id/acceptance`],
    [Pending #sym.arrow Accepted],
    text(fill: item-color)[Available #sym.arrow Reserved],
    [`Offers::AcceptancesController`],
    text(fill: seller-color)[Seller],

    [`POST .../offers/:id/rejection`],
    [Pending #sym.arrow Rejected],
    [—],
    [`Offers::RejectionsController`],
    text(fill: seller-color)[Seller],

    [`POST .../offers/:id/counter`],
    [Pending #sym.arrow Countered],
    [—],
    [`Offers::CountersController`],
    text(fill: seller-color)[Seller],

    [`POST .../offers/:id/counter_acceptance`],
    [Countered #sym.arrow Accepted],
    text(fill: item-color)[Available #sym.arrow Reserved],
    [`Offers::CounterAcceptancesController`],
    text(fill: buyer-color)[Buyer],

    [`POST .../offers/:id/counter_rejection`],
    [Countered #sym.arrow Rejected],
    [—],
    [`Offers::CounterRejectionsController`],
    text(fill: buyer-color)[Buyer],

    [`PATCH /items/:item_id/offers/:id`],
    [Pending #sym.arrow Pending \ Countered #sym.arrow Pending],
    [—],
    [`OffersController#update`],
    text(fill: buyer-color)[Buyer],

    [`DELETE /items/:item_id/offers/:id`],
    [Pending / Countered #sym.arrow _(destroyed)_],
    [—],
    [`OffersController#destroy`],
    text(fill: buyer-color)[Buyer],

    [`POST .../offers/:offer_id/review`],
    [Accepted #sym.arrow Completed],
    text(fill: item-color)[Reserved #sym.arrow Sold],
    [`ReviewsController#create`],
    text(fill: buyer-color)[Buyer],
  )
]
