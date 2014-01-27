require_relative 'helper'
require_relative '../models/purchase'

class TestPurchase < GroceryTest
  def test_to_s_prints_details
    purchase = Purchase.new(name: "Foo", price: "1.50", calories: "10")
    expected = "Foo: 10 calories, $1.50, id: #{purchase.id}"
    assert_equal expected, purchase.to_s
  end

  def test_update_doesnt_insert_new_row
    purchase = Purchase.create(name: "Foo", price: "1.50", calories: "10")
    foos_before = database.execute("select count(id) from purchases")[0][0]
    purchase.update(name: "Bar")
    foos_after = database.execute("select count(id) from purchases")[0][0]
    assert_equal foos_before, foos_after
  end

  def test_update_saves_to_the_database
    purchase = Purchase.create(name: "Foo", price: "1.50", calories: "10")
    id = purchase.id
    purchase.update(name: "Bar", price: "2.50", calories: "20")
    updated_purchase = Purchase.find(id)
    expected = ["Bar", "2.50", 20 ]
    actual = [ updated_purchase.name, updated_purchase.price, updated_purchase.calories]
    assert_equal expected, actual
  end

  def test_update_is_reflected_in_existing_instance
    purchase = Purchase.create(name: "Foo", price: "1.50", calories: "10")
    purchase.update(name: "Bar", price: "2.50", calories: "20")
    expected = ["Bar", "2.50", "20" ]
    actual = [ purchase.name, purchase.price, purchase.calories]
    assert_equal expected, actual
  end

  def test_saved_purchases_are_saved
    purchase = Purchase.new(name: "Foo", price: "1.50", calories: "10")
    foos_before = database.execute("select count(id) from purchases")[0][0]
    purchase.save
    foos_after = database.execute("select count(id) from purchases")[0][0]
    assert_equal foos_before + 1, foos_after
  end

  def test_save_creates_an_id
    purchase = Purchase.create(name: "Foo", price: "1.50", calories: "10")
    refute_nil purchase.id, "Purchase id shouldn't be nil"
  end

  def test_find_returns_nil_if_unfindable
    assert_nil Purchase.find(12342)
  end

  def test_find_returns_the_row_as_purchase_object
    purchase = Purchase.create(name: "Foo", price: "1.50", calories: "10")
    found = Purchase.find(purchase.id)
    # Ideally: assert_equal purchase, found
    # Hacky way so that we can focus on today's material:
    assert_equal purchase.name, found.name
    assert_equal purchase.id, found.id
  end

  def test_all_returns_all_purchases_in_alphabetical_order
    Purchase.create(name: "foo", calories: 130, price: 1.50)
    Purchase.create(name: "bar", calories: 530, price: 1.00)
    results = Purchase.all
    expected = ["bar", "foo"]
    actual = results.map{ |purchase| purchase.name }
    # ^ is equivalent to:
    # actual = []
    # results.each do |purchase|
    #   actual << purchase.name
    # end
    assert_equal expected, actual
  end

  def test_all_returns_empty_array_if_no_purchases
    results = Purchase.all
    assert_equal [], results
  end
end