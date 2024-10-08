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

actor {
  type JSON = {
    #Object : [(Text, JSON)];
    #Array : [JSON];
    #String : Text;
    #Number : Float;
    #Bool : Bool;
    #Null;
  };

  stable var jsonText : Text = "";

  public func setJSON(json : Text) : async () {
    let cleanedJson = Text.map(json, func (c : Char) : Char {
      if (c == '\n' or c == '\r' or c == '\t') { ' ' }
      else if (c == '\\') { '\\' }
      else if (c == '\"') { '\"' }
      else { c }
    });
    jsonText := cleanedJson;
  };

  public query func getJSON() : async Text {
    jsonText
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

  private func parseJSON(json : Text) : ?JSON {
    let trimmed = Text.trim(json, #text " \n\t\r");
    if (Text.size(trimmed) == 0) {
      return null;
    };
    switch (trimmed.chars().next()) {
      case (? '{') {
        let content = Text.trimStart(Text.trimEnd(trimmed, #text "}"), #text "{");
        let pairs = Iter.toArray(Text.split(content, #text ","));
        var result : [(Text, JSON)] = [];
        for (pair in pairs.vals()) {
          let kv = Text.split(pair, #text ":");
          let key = Text.trim(Iter.toArray(kv)[0], #text "\"");
          let value = Text.trim(Iter.toArray(kv)[1], #text " ");
          switch (parseJSON(value)) {
            case (?parsedValue) {
              result := Array.append(result, [(key, parsedValue)]);
            };
            case (null) {};
          };
        };
        ?#Object(result);
      };
      case (? '[') {
        let content = Text.trimStart(Text.trimEnd(trimmed, #text "]"), #text "[");
        let items = Iter.toArray(Text.split(content, #text ","));
        var result : [JSON] = [];
        for (item in items.vals()) {
          switch (parseJSON(Text.trim(item, #text " "))) {
            case (?parsedValue) {
              result := Array.append(result, [parsedValue]);
            };
            case (null) {};
          };
        };
        ?#Array(result);
      };
      case (? '\"') {
        ?#String(Text.trim(trimmed, #text "\""));
      };
      case (? 't') {
        if (trimmed == "true") { ?#Bool(true) } else { null };
      };
      case (? 'f') {
        if (trimmed == "false") { ?#Bool(false) } else { null };
      };
      case (? 'n') {
        if (trimmed == "null") { ?#Null } else { null };
      };
      case (_) {
        switch (textToFloat(trimmed)) {
          case (?f) { ?#Number(f) };
          case (null) { null };
        };
      };
    };
  };

  public query func accessJSONPath(path : Text) : async Text {
    let parsedJSON = switch (parseJSON(jsonText)) {
      case (null) { throw Error.reject("Invalid JSON") };
      case (?value) { value };
    };

    let pathParts = Iter.toArray(Text.split(path, #char '.'));
    var current = parsedJSON;

    for (part in pathParts.vals()) {
      switch (current) {
        case (#Object(obj)) {
          switch (Array.find(obj, func((k, _) : (Text, JSON)) : Bool { k == part })) {
            case (?(_, value)) { 
              current := value;
            };
            case (null) { return "Path not found: " # path };
          };
        };
        case (#Array(arr)) {
          switch (Nat.fromText(part)) {
            case (?index) {
              if (index < arr.size()) {
                current := arr[index];
              } else {
                return "Array index out of bounds: " # path;
              };
            };
            case (null) { return "Invalid array index: " # path };
          };
        };
        case _ { return "Cannot access property of non-object/non-array: " # path };
      };
    };

    switch (current) {
      case (#String(s)) { s };
      case (#Number(n)) { Float.toText(n) };
      case (#Bool(b)) { Bool.toText(b) };
      case (#Null) { "null" };
      case (#Object(_)) { "<object>" };
      case (#Array(_)) { "<array>" };
    };
  };
}
