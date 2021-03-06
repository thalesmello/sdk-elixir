defmodule StarkBank.BoletoPayment.Log do

  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.BoletoPayment, as: BoletoPayment
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups BoletoPayment.Log related functions
  """

  @doc """
  Every time a BoletoPayment entity is modified, a corresponding BoletoPayment.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the BoletoPayment.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - payment [BoletoPayment]: BoletoPayment entity to which the log refers to.
    - errors [list of strings]: list of errors linked to this BoletoPayment event.
    - type [string]: type of the BoletoPayment event which triggered the log creation. ex: "registered" or "paid"
    - created [DateTime]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :payment, :errors, :type, :created]
  defstruct [:id, :payment, :errors, :type, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Log struct with updated attributes
  """
  @spec get(Project.t(), binary) :: {:ok, Log.t()} | {:error, [%Error{}]}
  def get(%Project{} = user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: Log.t()
  def get!(%Project{} = user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Receive a stream of Log structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - after [Date, default nil] date filter for entities created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for entities only before specified date. ex: Date(2020, 3, 10)
    - types [list of strings, default nil]: filter retrieved entities by event types. ex: "paid" or "registered"
    - payment_ids [list of strings, default nil]: list of BoletoPayment ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]

  ## Return:
    - stream of Log structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Log.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(%Project{} = user, options \\ []) do
    Rest.get_list(user, resource(), options |> Checks.check_options(true))
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(%Project{} = user, options \\ []) do
    Rest.get_list!(user, resource(), options |> Checks.check_options(true))
  end

  @doc false
  def resource() do
    {
      "BoletoPaymentLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      payment: json[:payment] |> API.from_api_json(&BoletoPayment.resource_maker/1),
      created: json[:created] |> Checks.check_datetime,
      type: json[:type],
      errors: json[:errors]
    }
  end
end
