defmodule SimpleBayes.Storage.Dets do
  @behaviour SimpleBayes.Storage.Behaviour

  def init(struct, opts) do
    opts   = Keyword.merge(struct.opts, opts)
    struct = %{struct | opts: opts}

    :dets.open_file(opts[:file_path], [])
    :dets.insert(opts[:file_path], {"data", struct})

    {:ok, pid} = Agent.start_link(fn -> struct end)

    pid
  end

  def save(pid, struct) do
    :dets.insert(struct.opts[:file_path], {"data", struct})
    :dets.sync(struct.opts[:file_path])

    {:ok, pid, nil}
  end

  def load(opts) do
    {:ok, reference}  = :dets.open_file(opts[:file_path])
    [{_, struct}] = :dets.lookup(reference, "data")

    {:ok, pid} = Agent.start_link(fn -> struct end)

    pid
  end
end
