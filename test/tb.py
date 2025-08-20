import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLK_NS = 45
EXPECTED_OE = 0xFF  # maschera OE attesa in GL

def has_xz(v): return 'x' in v.binstr.lower() or 'z' in v.binstr.lower()

@cocotb.test()
async def smoke(dut):
    """Smoke test valido per RTL e GL."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, units="ns").start())

    # ingressi default
    if hasattr(dut, "ena"):
        dut.ena.value = 1
    dut.ui_in.value  = 0 if hasattr(dut, "ui_in")  else 0
    if hasattr(dut, "uio_in"):
        dut.uio_in.value = 0

    # reset attivo-basso
    # RTL: top_module di solito ha 'rst'
    # GL: wrapper TT ha 'rst_n'
    if hasattr(dut, "rst_n"):
        dut.rst_n.value = 0
    elif hasattr(dut, "rst"):
        dut.rst.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    if hasattr(dut, "rst_n"):
        dut.rst_n.value = 1
    elif hasattr(dut, "rst"):
        dut.rst.value = 1

    for _ in range(10):
        await RisingEdge(dut.clk)

    # controlli base (senza X/Z)
    if hasattr(dut, "uo_out"):
        assert not has_xz(dut.uo_out.value), "uo_out ha X/Z dopo il reset"
    if hasattr(dut, "uio_out"):
        assert not has_xz(dut.uio_out.value), "uio_out ha X/Z dopo il reset"
    if hasattr(dut, "uio_oe"):
        assert not has_xz(dut.uio_oe.value), "uio_oe ha X/Z dopo il reset"
        assert int(dut.uio_oe.value) == EXPECTED_OE, f"uio_oe={int(dut.uio_oe.value):02X}, atteso {EXPECTED_OE:02X}"

    # piccola stimolazione sugli ingressi dedicati
    if hasattr(dut, "ui_in"):
        for i in range(4):
            dut.ui_in.value = i
            await RisingEdge(dut.clk)
