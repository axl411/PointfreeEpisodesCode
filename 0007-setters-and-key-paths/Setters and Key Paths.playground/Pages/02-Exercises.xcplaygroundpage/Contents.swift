/*:
 # Setters and Key Paths Exercises

 1. In this episode we used `Dictionary`’s subscript key path without explaining it much. For a `key: Key`, one can construct a key path `\.[key]` for setting a value associated with `key`. What is the signature of the setter `prop(\.[key])`? Explain the difference between this setter and the setter `prop(\.[key]) <<< map`, where `map` is the optional map.
 */
func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (Root)
    -> Root {
        return { update in
            { root in
                var copy = root
                copy[keyPath: kp] = update(copy[keyPath: kp])
                return copy
            }
        }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
    return { $0.map(f) }
}

let setter1 = prop(\[String: Int].["key"]) // (@escaping (Int?) -> Int?) -> ([String : Int]) -> [String : Int]
let setter2 = prop(\[String: Int].["key"]) <<< map // ((Int) -> Int) -> ([String : Int]) -> [String : Int]
/*:
 2. The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn't stop us from defining a functional setter! Define a function `elem` with signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the input determines if the value is already in the set and the output determines if the value should be included.
 */
func elem<A>(_ a: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
    return { transform in
        { set in
            var copy = set
            if transform(copy.contains(a)) {
                copy.insert(a)
            } else {
                copy.remove(a)
            }
            return copy
        }
    }
}

let set: Set<Int> = [1, 2, 3]
var newSet = set |> (elem(4)) { contained in return !contained }
newSet
newSet = (newSet |> (elem(2)) { contained in return !contained })
newSet
/*:
 3. Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */
struct Food {
    var name: String
}

struct Location {
    var name: String
}

struct User {
    var favoriteFoods: [Food]
    var location: Location
    var name: String
}

let user = User(
    favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
    location: Location(name: "Brooklyn"),
    name: "Blob"
)

//user
//    |> (prop(\.name)) { name in name + "!" }
let newUser = user
    |> (prop(\.favoriteFoods) <<< prop(\.[0]) <<< prop(\.name)) { $0.uppercased() }

//let boringUser = User(favoriteFoods: [], location: Location(name: "Brooklyn"), name: "Blob")
//boringUser
//    |> (prop(\.favoriteFoods) <<< prop(\.[0]) <<< prop(\.name)) { $0.uppercased() }
/*:
 4. Recall from a [previous episode](https://www.pointfree.co/episodes/ep5-higher-order-functions) that the free `filter` function on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
 */
func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
    return { $0.filter(p) }
}

let nne = user
    |> (prop(\User.favoriteFoods) <<< filter) { $0.name.hasPrefix("N") }
// perform a 'filter' on user's favoriteFoods
/*:
 5. Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing into those cases.
 */
enum Result<Value, Error> {
    case success(Value)
    case error(Error)
}

let result: Result<Int, Error> = .success(1)

result
    |> prop(\Result<Int, Error>.success) { success in success }
/*:
 6. Is it possible to make key path setters work with `enum`s?
 */
// TODO
/*:
 7. Redefine some of our setters in terms of `inout`. How does the type signature and composition change?
 */
// TODO
