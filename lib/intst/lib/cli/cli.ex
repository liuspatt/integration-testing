defmodule Intst.CLI do
  IO.inspect "Intst.CLI"
  def main(args) do
    options = [switches: [file: :string],aliases: [f: :file]]
    IO.inspect(args, label: "args")
    IO.inspect(options, label: "options")
    {opts,_,_}= OptionParser.parse(args, options)
    IO.inspect opts, label: "Command Line Arguments"
  end
end
