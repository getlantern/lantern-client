package io.lantern.model.dbadapter

import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import minisql.DB
import minisql.Rows
import minisql.Tx
import minisql.Values

open class DBAdapter(protected val db: SQLiteDatabase) : DB {
    override fun exec(sql: String?, args: Values?) = db.execSQL(sql, args?.toBindArgs())

    override fun query(sql: String?, args: Values?)= RowsAdapter(db.rawQuery(sql, args?.toSelectionArgs()))

    override fun begin() = TxAdapter(db)
}

class TxAdapter(db: SQLiteDatabase) : DBAdapter(db), Tx {
    init {
        db.beginTransaction()
    }

    override fun commit() {
        db.setTransactionSuccessful()
        db.endTransaction()
    }

    override fun rollback() {
        db.endTransaction()
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

fun Values.toBindArgs(): Array<Any> = Array<Any>(len().toInt()) {
    val arg = get(it.toLong())
    when (arg.type) {
        0L -> arg.bytes()
        1L -> arg.string()
        2L -> arg.int_()
        3L -> if (arg.bool()) 1 else 0
        else -> throw RuntimeException("unknown value type $arg.type")
    }
}

fun Values.toSelectionArgs(): Array<String> = toBindArgs().map { it.toString() }.toTypedArray()