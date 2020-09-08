
defmodule Cyndaquil.Web.SocketHandlers.Chat do
  @behaviour :cowboy_websocket

  def init(request, [%{supervisor: supervisor}]) do
    websocket_state =
      %{request: request, registry_key: request.path}
      |> Map.merge(%{supervisor: supervisor})

    {:cowboy_websocket, request, websocket_state}
  end

  def websocket_init(state) do
    {:ok, state}
  end

  def websocket_handle({:text, _json}, %{supervisor: _supervisor} = _state) do
    {:ok, :no_reply}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  @spec terminate(any, any, map) :: :ok
  def terminate(_reason, _req, _state) do
   

    :ok
  end
end
