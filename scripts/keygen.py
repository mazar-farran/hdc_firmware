#!/usr/bin/env python3
#
# Utility to generate private/public key pair.
# The private key may be used to generate a UBX-CFG-OTP message to write the eFuse


from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization
import binascii
import sys
private_key = ec.generate_private_key(ec.SECP384R1())
if (len(sys.argv)>1):
	type=int(sys.argv[1])
if (type==1): private_key = ec.generate_private_key(ec.SECP192R1())
elif (type==2): private_key = ec.generate_private_key(ec.SECP224R1())
elif (type==3): private_key = ec.generate_private_key(ec.SECP256K1())
elif (type==4): private_key = ec.generate_private_key(ec.SECP256R1())
elif (type==5): private_key = ec.generate_private_key(ec.SECP384R1())
elif (type==6): private_key = ec.generate_private_key(ec.SECP521R1())
elif (type==7): private_key = ec.generate_private_key(ec.BrainpoolP256R1())
elif (type==8): private_key = ec.generate_private_key(ec.BrainpoolP384R1())
elif (type==9): private_key = ec.generate_private_key(ec.BrainpoolP512R1())
vals = private_key.private_numbers()
no_bits=vals.private_value.bit_length()
print (f"Private key value: {vals.private_value}. Number of bits {no_bits}")
print (f"Private (d): {hex(vals.private_value)}")
public_key = private_key.public_key()
vals=public_key.public_numbers()
print (f"Public (Px): {hex(vals.x)}")
print (f"Public (Py): {hex(vals.y)}")
enc_point=binascii.b2a_hex(public_key.public_bytes(encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo)).decode()
print (f"\nPublic key encoded point: {enc_point} \nx={enc_point[2:(len(enc_point)-2)//2+2]} \ny={enc_point[(len(enc_point)-2)//2+2:]}")
pem = private_key.private_bytes(encoding=serialization.Encoding.PEM,format=serialization.PrivateFormat.PKCS8,encryption_algorithm=serialization.NoEncryption())
der = private_key.private_bytes(encoding=serialization.Encoding.DER,format=serialization.PrivateFormat.PKCS8,encryption_algorithm=serialization.NoEncryption())
print ("\nPrivate key (PEM):\n",pem.decode())
print ("Private key (DER):\n",binascii.b2a_hex(der))
pem = public_key.public_bytes(encoding=serialization.Encoding.PEM,format=serialization.PublicFormat.SubjectPublicKeyInfo)
der = public_key.public_bytes(encoding=serialization.Encoding.DER,format=serialization.PublicFormat.SubjectPublicKeyInfo)
print ("\nPublic key (PEM):\n",pem.decode())
print ("Public key (DER):\n",binascii.b2a_hex(der))
