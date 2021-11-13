//
//  Crash.swift
//
//
//  Created by 韦烽传 on 2021/11/13.
//

import Foundation

/**
 崩溃
 */
open class Crash {
    
    /**
     信号捕获
     */
    static let signalCatch: @convention(c) (Int32) -> Void = { signal in
        
        var userInfo: [AnyHashable: Any] = [:]
        
        userInfo["UncaughtExceptionHandlerSignalKey"] = signal
        userInfo["UncaughtExceptionHandlerAddressesKey"] = Thread.callStackReturnAddresses
        userInfo["UncaughtExceptionHandlerSymbolsKey"] = Thread.callStackSymbols
        
        let exception = NSException(name: NSExceptionName(rawValue: "UncaughtExceptionHandlerSignalExceptionName"), reason: "Signal \(signal) was raised.", userInfo: userInfo)
        
        callback(exception)
        
        removeSignal()
    }
    
    /**
     OC捕获
     */
    static let exceptionCatch: @convention(c) (NSException) -> Void = { exception in
        
        callback(exception)
    }
    
    /// 回调
    public static var callback: (NSException) -> Void = {_ in }
    
    /**
     开始捕获崩溃
     */
    public static func start() {
                
        NSSetUncaughtExceptionHandler(exceptionCatch)
        addSignal()
    }
    
    /**
     添加信号
     */
    static func addSignal() {
        
        signal(SIGABRT, signalCatch)
        signal(SIGILL, signalCatch)
        signal(SIGSEGV, signalCatch)
        signal(SIGFPE, signalCatch)
        signal(SIGBUS, signalCatch)
        signal(SIGPIPE, signalCatch)
        signal(SIGTRAP, signalCatch)
    }
    
    /**
     删除信号
     */
    static func removeSignal() {
        
        NSSetUncaughtExceptionHandler(nil)
        
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        
        kill(getpid(), SIGKILL)
    }
}
