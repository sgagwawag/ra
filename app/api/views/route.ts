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
  
  // Increment the view count
  const { data, error } = await supabase.rpc("increment_views")

  if (error) {
    // If RPC doesn't exist, do a manual update
    const { data: updateData, error: updateError } = await supabase
      .from("page_views")
      .update({ 
        view_count: supabase.raw("view_count + 1"),
        updated_at: new Date().toISOString()
      })
      .eq("id", "homepage")
      .select("view_count")
      .single()

    if (updateError) {
      console.error("Error updating views:", updateError)
      return NextResponse.json({ views: 0 }, { status: 500 })
    }

    return NextResponse.json({ views: updateData?.view_count ?? 0 })
  }

  return NextResponse.json({ views: data ?? 0 })
}
