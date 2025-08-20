New-Item -ItemType Directory build -ErrorAction SilentlyContinue | Out-Null
$TOP = "top_module_tb"

# Compila RTL
iverilog -g2012 -Wall -s $TOP -o build/sim.vvp `
  test\top_module_tb.v `
  src\top_module.v `
  src\IO_controller.v `
  src\control_unit.v `
  src\ALU_controller.v `
  src\ALU.v `
  src\register_port.v `
  src\extender.v `
  src\MUX.v `
  src\CORE.v

if ($LASTEXITCODE -ne 0) { exit 1 }

# Esegui
vvp build\sim.vvp

# Apri le waveform (se hai installato GTKWave)
if (Test-Path ".\top_module_tb.vcd") {
  try { Start-Process gtkwave ".\top_module_tb.vcd" } catch { Write-Host "Apri tb_top_module.vcd con il tuo viewer" }
}
