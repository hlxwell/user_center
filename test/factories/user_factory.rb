Factory.define :user do |u|
  u.sequence(:email) { |n| "user#{n}@example.com" }
  u.password "password"
  u.activation_state "active"
end