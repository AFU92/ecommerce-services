# frozen_string_literal: true

customers = [
  { customer_name: "Juan Perez",   address: "Calle 10 # 20-30, Bogotá",        orders_count: 0 },
  { customer_name: "Maria Gomez",  address: "Cra 7 # 12-34, Medellín",         orders_count: 0 },
  { customer_name: "Carlos Ruiz",  address: "Av 3 # 15-20, Cúcuta",            orders_count: 0 },
  { customer_name: "Laura Diaz",   address: "Calle 45 # 9-10, Barranquilla",   orders_count: 0 },
  { customer_name: "Andres Mora",  address: "Cra 80 # 30-15, Cali",            orders_count: 0 }
]

ActiveRecord::Base.transaction do
  customers.each do |attrs|
    customer = Customer.find_or_initialize_by(
      customer_name: attrs[:customer_name],
      address: attrs[:address]
    )

    customer.orders_count = attrs[:orders_count] if customer.orders_count.nil?
    customer.save!
  end
end

puts "Seeded #{Customer.count} customers"
