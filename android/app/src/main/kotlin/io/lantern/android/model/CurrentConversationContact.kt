package io.lantern.android.model

/**
 * Handle the person who the user is currently talking to.
 * This is handled as an object due to the advantage of being static and also being a singleton.
 * Refers: https://stackoverflow.com/questions/54493959/what-is-difference-between-object-and-data-class-in-kotlin
 */
object CurrentConversationContact {
    var activeConversationId: String = ""
}