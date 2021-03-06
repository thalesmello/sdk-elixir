defmodule StarkBankTest.BoletoPayment do
  use ExUnit.Case

  @tag :boleto_payment
  test "create boleto payment" do
    user = StarkBankTest.Credentials.project()
    {:ok, payments} = StarkBank.BoletoPayment.create(user, [example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :boleto_payment
  test "create! boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.create!(user, [example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :boleto_payment
  test "query boleto payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.BoletoPayment.query(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment
  test "query! boleto payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.BoletoPayment.query!(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment
  test "get boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _payment} = StarkBank.BoletoPayment.get(user, payment.id)
  end

  @tag :boleto_payment
  test "get! boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.query!(user)
     |> Enum.take(1)
     |> hd()
    _payment = StarkBank.BoletoPayment.get!(user, payment.id)
  end

  @tag :boleto_payment
  test "pdf boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.BoletoPayment.pdf(user, payment.id)
  end

  @tag :boleto_payment
  test "pdf! boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.BoletoPayment.pdf!(user, payment.id)
    file = File.open!("boleto-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :boleto_payment
  test "delete boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.create!(user, [example_payment()]) |> hd
    {:ok, deleted_payment} = StarkBank.BoletoPayment.delete(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :boleto_payment
  test "delete! boleto payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.BoletoPayment.create!(user, [example_payment()]) |> hd
    deleted_payment = StarkBank.BoletoPayment.delete!(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  defp example_payment() do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.create!(user, [StarkBankTest.Boleto.example_boleto()]) |> hd
    %StarkBank.BoletoPayment{
      line: boleto.line,
      scheduled: Date.utc_today() |> Date.add(1),
      description: "loading a random account",
      tax_id: boleto.tax_id
    }
  end
end
