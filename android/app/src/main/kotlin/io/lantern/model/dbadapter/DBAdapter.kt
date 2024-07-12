package io.lantern.model.dbadapter

import android.database.Cursor
import android.util.Log
import minisql.DB
import minisql.Rows
import minisql.Tx
import minisql.Values
import net.sqlcipher.database.SQLiteDatabase
import java.util.UUID

open class DBAdapter(val db: SQLiteDatabase) : DB {
    init {
        setPragmaSettings()
    }
    private fun setPragmaSettings() {
        db.query("PRAGMA journal_mode = WAL")
        db.query("PRAGMA busy_timeout = 5000")
    }

    override fun exec(sql: String, args: Values?) = db.execSQL(sql, args!!.toBindArgs())

    override fun query(sql: String?, args: Values?) =
        RowsAdapter(db.rawQuery(sql, args?.toBindArgs()))

    override fun begin(): Tx {
        Log.d("Database", "BEGIN")
        return TxAdapter(db);
    }
}

class TxAdapter(private val sqliteDB: SQLiteDatabase) : DBAdapter(sqliteDB), Tx {
    val id = UUID.randomUUID().toString()
    @Volatile
    private var isSavepointActive = false

    init {
        createSavepoint()
    }

    @Synchronized
    private fun createSavepoint() {
        if (!isSavepointActive) {
            sqliteDB.execSQL("SAVEPOINT ${id.quote()}")
            Log.d("Database", "SAVEPOINT ${id.quote()} created")
            isSavepointActive = true
        } else {
            Log.w("Database", "Attempted to create nested savepoint: ${id.quote()}")
        }
    }

    @Synchronized
    override fun commit() {
        if (isSavepointActive) {
            sqliteDB.execSQL("RELEASE ${id.quote()}")
            Log.d("Database", "RELEASE ${id.quote()}")
            isSavepointActive = false
        } else {
            Log.w("Database", "No active savepoint to release")
        }
    }

    @Synchronized
    override fun rollback() {
        if (isSavepointActive) {
            sqliteDB.execSQL("ROLLBACK TO ${id.quote()}")
            Log.d("Database", "ROLLBACK TO ${id.quote()}")
            isSavepointActive = false
        } else {
            Log.w("Database", "No active savepoint to rollback to")
        }
    }

    private fun String.quote(): String {
        return "'${this.replace("'", "''")}'"
    }
}

class RowsAdapter(private val cursor: Cursor) : Rows {
    override fun next() = cursor.moveToNext()

    override fun scan(values: Values?) {
        values?.let { it ->
            for (i in 0 until it.len().toInt()) {
                val v = it.get(i.toLong())
                when (v.type) {
                    0L -> v.setBytes(cursor.getBlob(i))
                    1L -> v.setString(cursor.getString(i))
                    2L -> v.setInt(cursor.getLong(i))
                    3L -> v.setBool(cursor.getInt(i) == 1)
                    else -> throw RuntimeException("unknown value type $v.type")
                }
            }
        }
    }

    override fun close() = cursor.close()
}

fun Values.toBindArgs(): Array<Any?> = Array<Any?>(len().toInt()) {
    val arg = get(it.toLong())
    when (arg.type) {
        0L -> arg.bytes()
        1L -> arg.string()
        2L -> arg.int_()
        3L -> if (arg.bool()) 1 else 0
        else -> throw RuntimeException("unknown value type $arg.type")
    }
}