//
//  CursorChatView.swift
//  Psychosis
//
//  Created on [Current Date]
//

import SwiftUI

struct CursorChatView: View {
    let file: FileItem?
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Connection Status
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(isConnected ? "Cursor Connected" : "Not Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Connect") {
                    // TODO: Connect to Cursor chat
                    isConnected = true
                }
                .buttonStyle(.bordered)
                .disabled(isConnected)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if messages.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("Cursor Chat")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Connect to Cursor to start chatting about your code")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { oldCount, newCount in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input
            HStack(spacing: 12) {
                TextField("Ask Cursor about your code...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(!isConnected)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(inputText.isEmpty || !isConnected ? .gray : .blue)
                }
                .disabled(inputText.isEmpty || isLoading || !isConnected)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty && isConnected else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            role: .user,
            content: inputText,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let messageToSend = inputText
        inputText = ""
        isLoading = true
        
        Task {
            // TODO: Send message to Cursor chat API
            // This would connect to the Cursor chat endpoint
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate delay
            
            let response = ChatMessage(
                id: UUID(),
                role: .assistant,
                content: "Cursor chat response would appear here. Connect to Cursor API to enable.",
                timestamp: Date()
            )
            
            await MainActor.run {
                messages.append(response)
                isLoading = false
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
}

enum MessageRole {
    case user
    case assistant
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(
                        message.role == .user
                            ? Color.blue
                            : Color(.systemGray5)
                    )
                    .foregroundColor(
                        message.role == .user
                            ? .white
                            : .primary
                    )
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

#Preview {
    CursorChatView(file: nil)
        .background(Color.black)
}


