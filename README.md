## 68K Disassembler

Group Members
  - Thomas Kercheval
  - Saam Amiri
  - Natalia Gilbertson

### Contest Entered:
  - Most Opcodes (Extensive 68K Disassembler)
  - 23 Extra opcodes are supported (and all 30 required)
  - See `68K_Disassembler/deliverables/Program_Specification.pdf` for list

### Instructions
  Generic instructions here. More specific instructions found in Project
  Specification deliverable.

  - Open `68K_Disassembler/src/io_NataliaGilbertson.x68` in `Easy68K`
  - Execute file
  - Load program to disassemble into memory
  - Begin execution of I/O module
  - Specify address ranges to disassemble between
    - Both start and end must be word aligned
    - Sign extension is supported
      - Start at `7FFE`, end at `8000` will disassemble `7FFE` -> `FF8000`
  - Press enter to begin process
  - Press enter to print next page

### Deliverables
  - Source files found in `68K_Disassembler/src`
  - Other specified deliverables found in `68K_Disassembler/deliverables`
  - Design documents found in `68K_Disassembler/documentation`

### Test File
  - `68K_Disassembler/src/test_code/op_codes_to_test.x68`
  - `ORG`'d at $1000

