defmodule Earmark.Extension do
  use GenServer

  @moduledoc """

  Define a module with a `render()` function.

  ```
  defmodule Markdown.Echo do
    def render(input) do
      html = input
      { :ok, html }
    end
  end
  ```

  Add `Earmark.Extension` to your child processes, including an entry to your extension.

  ```
  def start(_type, _args) do
    ...
    children = [
      ...
      { Earmark.Extension, %{ echo: Markdown.Echo } },
      ...
    ]
    ...
  end
  ```

  """

  def start_link(registrations) do
    GenServer.start_link(__MODULE__, registrations, name: __MODULE__)
  end

  def register(id, module) do
    GenServer.call(__MODULE__, {:register, id, module})
  end

  def render(id, input) do
    GenServer.call(__MODULE__,{:render, id, input})
  end

  @impl true
  def init(state) do
    { :ok, state }
  end

  @impl true
  def handle_call({:render, id, input }, _from, state) do
    output = case Map.fetch(state, String.to_atom(id)) do
      { :ok, module } ->
        apply(module, :render, [input])
      :error ->
        :error
    end
    {:reply, output, state}
  end

  @impl true
  def handle_call({:register, id, module }, _from, state) do
    state = Map.put(state, id, module)
    { :reply, :ok, state }
  end

end
