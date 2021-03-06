defmodule StarkBank.Boleto.Log do

  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Boleto, as: Boleto
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups Boleto.Log related functions
  """

  @doc """
  Every time a Boleto entity is updated, a corresponding Boleto.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the Boleto.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - boleto [Boleto]: Boleto entity to which the log refers to.
    - errors [list of strings]: list of errors linked to this Boleto event
    - type [string]: type of the Boleto event which triggered the log creation. ex: "registered" or "paid"
    - created [DateTime]: creation datetime for the boleto. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :boleto, :errors, :type, :created]
  defstruct [:id, :boleto, :errors, :type, :created]

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
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - after [Date, default nil] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for structs only before specified date. ex: Date(2020, 3, 10)
    - types [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
    - boleto_ids [list of strings, default nil]: list of Boleto ids to filter logs. ex: ["5656565656565656", "4545454545454545"]

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
      "BoletoLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      boleto: json[:boleto] |> API.from_api_json(&Boleto.resource_maker/1),
      created: json[:created] |> Checks.check_datetime,
      type: json[:type],
      errors: json[:errors]
    }
  end
end
