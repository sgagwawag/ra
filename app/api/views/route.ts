import { createClient } from "@/lib/supabase/server"
import { NextResponse } from "next/server"

export async function GET() {
  const supabase = await createClient()
  
  const { data, error } = await supabase
    .from("page_views")
    .select("view_count")
    .eq("id", "homepage")
    .single()

  if (error) {
    console.error("Error fetching views:", error)
    return NextResponse.json({ views: 0 }, { status: 500 })
  }

  return NextResponse.json({ views: data?.view_count ?? 0 })
}

export async function POST() {
  const supabase = await createClient()
  
  // Increment the view count using the RPC function
  const { data, error } = await supabase.rpc("increment_views")

  if (error) {
    console.error("Error incrementing views:", error)
    return NextResponse.json({ views: 0 }, { status: 500 })
  }

  return NextResponse.json({ views: data ?? 0 })
}
