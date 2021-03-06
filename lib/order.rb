require 'csv'

class Order
  attr_reader :id, :products, :customer, :fulfillment_status

  def initialize(id, products, customer, fulfillment_status = :pending)
    statuses = %i[pending paid processing shipped complete]
    if !statuses.include?(fulfillment_status)
      raise ArgumentError.new("#{fulfillment_status} is an INVALID status.")
    end
    @id = id
    @products = products
    @customer = customer
    @fulfillment_status = fulfillment_status
  end

  def total
    sum = products.values.sum
    tax = sum * 0.075
    total = (sum + tax).round(2)
    return total
  end

  def add_product(name, price)
    if products.has_key?(name)
      raise ArgumentError.new("#{name} has already been added to the order")
    end
    products[name] = price
  end

  # optional
  def remove_product(name)
    product_removed = products.delete(name)
    unless product_removed
      raise ArgumentError.new("#{name} does not exist in the order")
    end
  end

  # returns array of order objects
  def self.all
    orders = CSV.read('data/orders.csv').map do |order|
      id = order[0].to_i
      products = {}
      products_array = order[1].split(";")
      products_array.each do |product|
        name = product.split(":")[0]
        price = product.split(":")[1].to_f
        products[name] = price
      end
      customer_id = order[2].to_i
      customer = Customer.find(customer_id)
      status = order[3].to_sym
      Order.new(id, products, customer, status)
    end
    return orders
  end

  # returns an order object with id.
  def self.find(id)
    all.find { |order| order.id == id }
  end

  # optional
  # returns list of order objects that match customer id
  def self.find_by_customer(customer_id)
    orders = all.filter { |order| order.customer.id == customer_id}
    orders.empty? ? nil : orders
  end
end
