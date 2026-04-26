import { ViewCounter } from "@/components/view-counter"

export default function Home() {
  return (
    <main className="min-h-screen bg-black flex flex-col items-center justify-center p-4 gap-6">
      <div className="w-full max-w-4xl">
        <video
          className="w-full rounded-lg shadow-2xl"
          controls
          autoPlay
          muted
          loop
          playsInline
        >
          <source
            src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Trumps-FZeyHkLNlnhRxb9xciGRAx2tZNbYE1.mp4"
            type="video/mp4"
          />
          Your browser does not support the video tag.
        </video>
      </div>
      <ViewCounter />
    </main>
  )
}
