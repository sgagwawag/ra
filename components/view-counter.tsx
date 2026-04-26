"use client"

import { useEffect, useState } from "react"

export function ViewCounter() {
  const [views, setViews] = useState<number | null>(null)

  useEffect(() => {
    // Increment view count on page load
    const trackView = async () => {
      try {
        const res = await fetch("/api/views", { method: "POST" })
        const data = await res.json()
        setViews(data.views)
      } catch (error) {
        console.error("Failed to track view:", error)
        // Try to at least get the current count
        try {
          const res = await fetch("/api/views")
          const data = await res.json()
          setViews(data.views)
        } catch {
          setViews(0)
        }
      }
    }

    trackView()
  }, [])

  return (
    <div className="flex items-center gap-2 text-white/80 text-sm">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z" />
        <circle cx="12" cy="12" r="3" />
      </svg>
      <span>
        {views === null ? "..." : views.toLocaleString()} views
      </span>
    </div>
  )
}
