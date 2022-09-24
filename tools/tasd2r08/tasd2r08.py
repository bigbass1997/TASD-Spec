#!/usr/bin/env python3

# Copyright (c) 2022, Vi Grey
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.


import sys
import os

def print_help():
    print("Usage: python3 tasd2r08 <input file path> <output file path>\r\n" +
          "Example: python3 tasd2r08 ~/TAS/smb.tasd /tmp/smb.r08")

def handle_packet(offset):
    init_offset = offset
    global infile_data
    global infile_len
    global tasd_g_len
    packet_type = int.from_bytes(infile_data[offset: offset + tasd_g_len],
                                 byteorder="big", signed=False)
    offset += tasd_g_len
    if offset >= infile_len:
        return (1, b"", offset)
    packet_exp = infile_data[offset]
    offset += 1
    if offset + packet_exp >= infile_len:
        return (1, b"", offset)
    packet_len = int.from_bytes(infile_data[offset: offset + packet_exp],
                                byteorder="big", signed=False)
    offset += packet_exp
    if offset + packet_len > infile_len:
        return (1, b"", offset)
    if packet_type != 0xfe01:
        offset += packet_len
        return (1, b"", offset)
    return (infile_data[offset],
            infile_data[offset + 1: offset + packet_len],
            offset + packet_len)

def main():
    global infile_data
    global infile_len
    global tasd_g_len
    if len(sys.argv) != 3:
        print_help()
        sys.exit(0)
    infile_name = sys.argv[1]
    outfile_name = sys.argv[2]
    outfile_data = b""
    try:
        infile = open(infile_name, "rb")
        infile_data = infile.read()
        infile.close()
    except:
        print("Unable to read input file " + infile_name)
        print("Exiting")
        sys.exit(1)
    if os.path.exists(outfile_name):
        print("File " + outfile_name + " already exists")
        reply = input("Overwrite file? [yes/No] ").lower()
        if reply != "yes" and reply != "y":
            print("Canceling conversion.  No files were written to.")
            print("Exiting")
            sys.exit(1)
    infile_len = len(infile_data)
    if infile_len < 7:
        print("Input file is not a TASD file (File not long enough to be a" +
              "TASD file)")
        print("Exiting")
        sys.exit(1)
    if infile_data[0:4] != b"TASD":
        print("Input file is not a TASD file (Invalid file header)")
        print("Exiting")
        sys.exit(1)
    tasd_version = int.from_bytes(infile_data[4:6], byteorder="big",
                                  signed=False)
    tasd_g_len = infile_data[6]
    if tasd_version != 1:
        print("Input file is not using a valid TASD file version")
        print("Exiting")
        sys.exit(1)
    # set infile_offset to after TASD file header, which is 7 bytes long
    infile_offset = 7
    while infile_offset + tasd_g_len < infile_len:
        (port, data, infile_offset) = handle_packet(infile_offset)
        if len(data) > 0:
            r08Data[port] += data
    r08MaxLen = 0
    for port in r08Data:
        dataLen = len(r08Data[port])
        if dataLen > r08MaxLen:
            r08MaxLen = dataLen
    for port in r08Data:
        dataLen = len(r08Data[port])
        if dataLen < r08MaxLen:
            r08Data[port] += b"\xff" * (r08MaxLen - dataLen)
    for offset in range(r08MaxLen):
        for port in sorted(r08Data):
            outfile_data += (r08Data[port][offset]^0xFF).to_bytes(1, "big")
    try:
        outfile = open(outfile_name, "wb")
        outfile.write(outfile_data)
        outfile.close()
    except:
        print("Unable to write output file " + infile_name)
        print("Exiting")
        sys.exit(1)
    print("Finished writing " + outfile_name)

infile_data = b""
infile_len = 0
tasd_g_len = 1
r08Data = {1: b"", 2: b""}
if __name__ == "__main__":
    main()
