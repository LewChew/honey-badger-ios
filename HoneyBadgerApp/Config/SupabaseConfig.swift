//
//  SupabaseConfig.swift
//  HoneyBadgerApp
//
//  Supabase configuration and shared client instance
//

import Foundation
import Supabase

struct SupabaseConfig {
    // MARK: - Configuration
    // Replace these with your actual Supabase project credentials
    // Get these from: Supabase Dashboard → Project Settings → API

    static let supabaseURL = "https://xtrrvtveycmezbzpaaxk.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0cnJ2dHZleWNtZXpienBhYXhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1MzQxMDIsImV4cCI6MjA1MTExMDEwMn0.tYuBiRsNW_1xrCfMTwEssPzDdOPnxmxlsQQi4h5EJnY"

    // MARK: - Shared Client Instance

    static let shared: SupabaseClient = {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }

        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseAnonKey
        )
    }()
}
