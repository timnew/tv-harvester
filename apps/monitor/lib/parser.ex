defmodule Parser do
  def start_link do
    Task.Supervisor.start_link(name: __MODULE__, restart: :transient)
  end

  def parse(name, dom) do
    method_name = List.to_existing_atom('parse_' ++ Atom.to_charlist(name))
    Task.Supervisor.start_child(__MODULE__, __MODULE__, method_name, [dom])
  end

  def parse_flash(dom) do
    dom
  end
end
