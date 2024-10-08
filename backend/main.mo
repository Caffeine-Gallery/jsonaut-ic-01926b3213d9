import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";

import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Char "mo:base/Char";
import Option "mo:base/Option";
import Result "mo:base/Result";

actor {
  type JSON = {
    #Object : [(Text, JSON)];
    #Array : [JSON];
    #String : Text;
    #Number : Float;
    #Bool : Bool;
    #Null;
  };

  type ParseResult = Result.Result<JSON, Text>;

  stable var jsonText : Text = "{\"name\":\"John Doe\",\"age\":30,\"address\":{\"street\":\"123 Main St\",\"city\":\"Anytown\"},\"hobbies\":[\"reading\",\"swimming\"]}";

  public func setJSON(json : Text) : async Result.Result<(), Text> {
    let cleanedJson = Text.map(json, func (c : Char) : Char {
      if (c == '\n' or c == '\r' or c == '\t') { ' ' }
      else if (c == '\\') { '\\' }
      else if (c == '\"') { '\"' }
      else { c }
    });
    
    switch (parseJSON(cleanedJson)) {
      case (#ok(_)) {
        jsonText := cleanedJson;
        #ok(());
      };
      case (#err(e)) {
        #err("Invalid JSON: " # e);
      };
    };
  };

  public query func getJSON() : async Text {
    jsonText;
  };

  private func textToFloat(t : Text) : ?Float {
    var f : Float = 0;
    var isNegative = false;
    var decimalPlace : Float = 0;
    for (c in t.chars()) {
      if (c == '-') {
        isNegative := true;
      } else if (c == '.') {
        decimalPlace := 0.1;
      } else {
        let d = Char.toNat32(c) - 48;
        if (d >= 0 and d <= 9) {
          if (decimalPlace == 0) {
            f := f * 10 + Float.fromInt(Nat32.toNat(d));
          } else {
            f += Float.fromInt(Nat32.toNat(d)) * decimalPlace;
            decimalPlace /= 10;
          };
        } else {
          return null;
        };
      };
    };
    if (isNegative) { f := -f };
    ?f;
  };

  private func parseJSONObject(content : Text) : ParseResult {
    let pairs = Iter.toArray(Text.split(content, #text ","));
    var result : [(Text, JSON)] = [];
    for (pair in pairs.vals()) {
      let kv = Text.split(pair, #text ":");
      let keyArr = Iter.toArray(kv);
      if (keyArr.size() < 2) {
        return #err("Invalid key-value pair: " # pair);
      };
      let key = Text.trim(keyArr[0], #text "\"");
      let value = Text.trim(Text.join(":", Array.slice(keyArr, 1, keyArr.size())), #text " ");
      switch (parseJSON(value)) {
        case (#ok(parsedValue)) {
          result := Array.append(result, [(key, parsedValue)]);
        };
        case (#err(e)) {
          return #err("Failed to parse value: " # e);
        };
      };
    };
    #ok(#Object(result));
  };

  private func parseJSONArray(content : Text) : ParseResult {
    let items = Iter.toArray(Text.split(content, #text ","));
    var result : [JSON] = [];
    for (item in items.vals()) {
      switch (parseJSON(Text.trim(item, #text " "))) {
        case (#ok(parsedValue)) {
          result := Array.append(result, [parsedValue]);
        };
        case (#err(e)) {
          return #err("Failed to parse array item: " # e);
        };
      };
    };
    #ok(#Array(result));
  };

  private func parseJSON(json : Text) : ParseResult {
    let trimmed = Text.trim(json, #text " \n\t\r");
    if (Text.size(trimmed) == 0) {
      return #err("Empty JSON");
    };
    switch (trimmed.chars().next()) {
      case (? '{') {
        let content = Text.trimStart(Text.trimEnd(trimmed, #text "}"), #text "{");
        parseJSONObject(content);
      };
      case (? '[') {
        let content = Text.trimStart(Text.trimEnd(trimmed, #text "]"), #text "[");
        parseJSONArray(content);
      };
      case (? '\"') {
        #ok(#String(Text.trim(trimmed, #text "\"")));
      };
      case (? 't') {
        if (trimmed == "true") { #ok(#Bool(true)) } else { #err("Invalid boolean value") };
      };
      case (? 'f') {
        if (trimmed == "false") { #ok(#Bool(false)) } else { #err("Invalid boolean value") };
      };
      case (? 'n') {
        if (trimmed == "null") { #ok(#Null) } else { #err("Invalid null value") };
      };
      case (_) {
        switch (textToFloat(trimmed)) {
          case (?f) { #ok(#Number(f)) };
          case (null) { #err("Invalid number") };
        };
      };
    };
  };

  public query func accessJSONPath(path : Text) : async Result.Result<Text, Text> {
    switch (parseJSON(jsonText)) {
      case (#err(e)) { 
        #err("Invalid JSON: " # e);
      };
      case (#ok(parsedJSON)) {
        let pathParts = Iter.toArray(Text.split(path, #char '.'));
        var current = parsedJSON;
        for (part in pathParts.vals()) {
          switch (current) {
            case (#Object(obj)) {
              switch (Array.find(obj, func((k, _) : (Text, JSON)) : Bool { k == part })) {
                case (?(_, value)) { 
                  current := value;
                };
                case (null) { 
                  return #err("Path not found: " # path);
                };
              };
            };
            case (#Array(arr)) {
              switch (Nat.fromText(part)) {
                case (?index) {
                  if (index < arr.size()) {
                    current := arr[index];
                  } else {
                    return #err("Array index out of bounds: " # path);
                  };
                };
                case (null) { 
                  return #err("Invalid array index: " # path);
                };
              };
            };
            case _ { 
              return #err("Cannot access property of non-object/non-array: " # path);
            };
          };
        };
        #ok(
          switch (current) {
            case (#String(s)) { s };
            case (#Number(n)) { Float.toText(n) };
            case (#Bool(b)) { Bool.toText(b) };
            case (#Null) { "null" };
            case (#Object(_)) { "<object>" };
            case (#Array(_)) { "<array>" };
          }
        );
      };
    };
  };
};
