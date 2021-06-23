import 'package:flutter/material.dart';
import 'package:FlashChat/components/messageBubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedinuser;
final _auth = FirebaseAuth.instance;

