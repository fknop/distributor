defmodule DistributorWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use DistributorWeb, :controller
      use DistributorWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: DistributorWeb

      import Plug.Conn
      import DistributorWeb.Gettext
      alias DistributorWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import DistributorWeb.Gettext
    end
  end

  def params do
    quote do
      use Ecto.Schema
      import Plug.Conn
      import Ecto.Changeset

      use Phoenix.Controller

      def init(options), do: options

      def call(conn, key) do
        changeset = __MODULE__.changeset(struct(__MODULE__), conn.params)

        if changeset.valid? do
          validated_params = Map.merge(struct(__MODULE__), changeset.changes)

          conn |> assign(key, validated_params)
        else
          conn
          |> put_status(:bad_request)
          |> json(%{errors: error_map(changeset)})
          |> halt
        end
      end

      defp error_map(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {_, value} ->
          Enum.into(value, %{}) |> filter_values
        end)
      end

      defp filter_values(%{constraint: value}), do: %{constraint: value}
      defp filter_values(value), do: value
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
