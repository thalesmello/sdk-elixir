# StarkBank

## Overview

This is a simplified pure Elixir SDK to ease integrations with the Auth and Charge sections of the [Stark Bank](https://starkbank.com) [API](https://docs.api.starkbank.com/?version=latest) v1.

## Installation

The package can be installed by adding `stark_bank` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stark_bank, "~> 1.0.0"}
  ]
end
```

## Usage

### Login

```elixir
{:ok, credentials} = StarkBank.Auth.login(:sandbox, "username", "email@email.com", "password")
```

### Register charge customers

```elixir
customers = [
  %StarkBank.Charge.Structs.CustomerData{
    name: "Arya Stark",
    email: "arya.stark@westeros.com",
    tax_id: "416.631.524-20",
    phone: "(11) 98300-0000",
    tags: ["little girl", "no one", "valar morghulis", "Stark"],
    address: %StarkBank.Charge.Structs.AddressData{
      street_line_1: "Av. Faria Lima, 1844",
      street_line_2: "CJ 13",
      district: "Itaim Bibi",
      city: "São Paulo",
      state_code: "SP",
      zip_code: "01500-000"
    }
  },
  %StarkBank.Charge.Structs.CustomerData{
    name: "Jon Snow",
    email: "jon.snow@westeros.com",
    tax_id: "012.345.678-90",
    phone: "(11) 98300-0001",
    tags: ["night`s watch", "lord commander", "knows nothing", "Stark"],
    address: %StarkBank.Charge.Structs.AddressData{
      street_line_1: "Av. Faria Lima, 1844",
      street_line_2: "CJ 13",
      district: "Itaim Bibi",
      city: "São Paulo",
      state_code: "SP",
      zip_code: "01500-000"
    }
  }
]

{:ok, customers} = StarkBank.Charge.Customer.register(credentials, customers)
```

### Get charge customers

```elixir
{:ok, all_customers} = StarkBank.Charge.Customer.get(credentials)
# or
{:ok, customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers).id)
```

### Get charge customers

```elixir
{:ok, all_customers} = StarkBank.Charge.Customer.get(credentials)
# or
{:ok, customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers).id)
```

### Delete charge customers

```elixir
{:ok, response} = StarkBank.Charge.Customer.delete(credentials, customers)
```

### Overwrite charge customers information

```elixir
{:ok, altered_customer} = StarkBank.Charge.Customer.overwrite(credentials, altered_customer)
```

### Create charges

```elixir
charges = [
  %StarkBank.Charge.Structs.ChargeData{
    amount: 10_000,
    customer: altered_customer.id
  },
  %StarkBank.Charge.Structs.ChargeData{
    amount: 100_000,
    customer: "self",
    due_date: Date.utc_today(),
    fine: 10,
    interest: 15,
    overdue_limit: 3,
    tags: ["cash-in"],
    descriptions: [
      %StarkBank.Charge.Structs.ChargeDescriptionData{
        text: "part-1",
        amount: 30_000
      },
      %StarkBank.Charge.Structs.ChargeDescriptionData{
        text: "part-2",
        amount: 70_000
      }
    ]
  }
]

{:ok, charges} = StarkBank.Charge.create(credentials, charges)
```

### Get created charges

```elixir
{:ok, all_charges} = StarkBank.Charge.get(credentials)
```

### Get charge PDF

```elixir
{:ok, pdf} =
  StarkBank.Charge.get_pdf(
    credentials,
    hd(all_charges).id
  )

{:ok, file} = File.open("charge.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

### Delete created charge

```elixir
StarkBank.Charge.delete(
  credentials,
  [hd(all_charges).id]
)
```

### Get charge logs

```elixir
{:ok, response} = StarkBank.Charge.Log.get(credentials, [hd(all_charges).id])
# or
{:ok, response} = StarkBank.Charge.Log.get_by_id(credentials, hd(charge_logs).id)
```