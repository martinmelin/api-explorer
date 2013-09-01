window.API_ENDPOINTS =
  GET: [
    "v1/stores/:store_id"
    "v1/stores/:store_id/followers"
    "v1/stores/:store_id/customers"
    "v1/stores/:store_id/customers/:customer_id"
    "v1/stores/:store_id/cards/:card_id"
    "v1/stores/:store_id/products"
    "v1/stores/:store_id/products/:product_id"
    "v1/stores/:store_id/orders",
    "v1/stores/:store_id/orders/:order_id"
  ]

  POST: [
    "v1/stores/:store_id/cards"
    "v1/stores/:store_id/followers"
  ]

  DELETE: [
    "v1/stores/:store_id/followers/:follower_id"
  ]
