defmodule StarkBank.Transfer.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Transfer, as: Transfer
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups Transfer.Log related functions
  """

  @doc """
  Every time a Transfer entity is modified, a corresponding Transfer.Log
  is generated for the entity. This log is never generated by the
  user.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - transfer [Transfer]: Transfer entity to which the log refers to.
    - errors [list of strings]: list of errors linked to this BoletoPayment event.
    - type [string]: type of the Transfer event which triggered the log creation. ex: "processing" or "success"
    - created [DateTime]: creation datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :transfer, :errors, :type, :created]
  defstruct [:id, :transfer, :errors, :type, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Log struct with updated attributes
  """
  @spec get(binary, [user: Project.t()]) :: {:ok, Log.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, [user: Project.t()]) :: Log.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Log structs previously created in the Stark Bank API

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - after [Date, default nil] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for structs only before specified date. ex: Date(2020, 3, 10)
    - types [list of strings, default nil]: filter retrieved structs by types. ex: "success" or "failed"
    - transfer_ids [list of strings, default nil]: list of Transfer ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - stream of Log structs with updated attributes
  """
  @spec query(any) ::
          ({:cont, {:ok, [Log.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options |> Checks.check_options(true))
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(any) ::
          ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options |> Checks.check_options(true))
  end

  @doc false
  def resource() do
    {
      "TransferLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      transfer: json[:transfer] |> API.from_api_json(&Transfer.resource_maker/1),
      created: json[:created] |> Checks.check_datetime(),
      type: json[:type],
      errors: json[:errors]
    }
  end
end
